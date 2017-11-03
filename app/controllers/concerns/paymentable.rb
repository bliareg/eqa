module Paymentable
  extend ActiveSupport::Concern

  MONTHLY_PRICE = 1000

  private

  def set_billing
    @billing = current_user.billing
    redirect_to :root unless @billing
  end

  def generate_client_token
    gon.client_token = Braintree::ClientToken.generate(customer_id: @billing.btree_customer_id)
  end

  def retrieve_calendar(is_regular, number_of_months, start_date)
    @date_arrays = []
    if is_regular
      number_of_months.times do
        @date_arrays += [[start_date, start_date.next_month.prev_day.end_of_day]]
        start_date += 1.month
      end
    else
      prev_date_array = @billing.regular_payments.with_status(:success).order(:id).last.periods
      prev_period_start = prev_date_array[0][0].to_datetime
      if start_date < prev_period_start
        @date_arrays = [[prev_period_start.prev_month.beginning_of_day, prev_period_start.prev_day.end_of_day]] + prev_date_array
      else
        current_period = find_current_period(prev_date_array, start_date)
        @date_arrays = prev_date_array[current_period..(prev_date_array.length - 1)]
      end
    end
  end

  def find_current_period(date_arrays, period_start)
    current_period = 0
    date_arrays.each_with_index do |date_period, i|
      if period_start >= date_period[0].to_datetime && period_start <= date_period[1].to_datetime
        current_period = i
        break
      end
    end
    current_period.to_i
  end

  def count_licenses_fee(licenses_amount, is_regular, number_of_months, start_day)
    @promocode ||= Promocode.find_by(token: params[:promocode])
    @promocode = nil if @promocode && @promocode.max_number_of_uses <= @promocode.number_of_uses
    @fee_per_new_license = count_fee_per_new_license(is_regular, number_of_months, start_day)
    generate_items(licenses_amount, start_day)
  end

  def count_fee_per_new_license(is_regular = true, number_of_months = 1, start_day = Time.now.utc.beginning_of_day)
    last_regular_payment = @billing.regular_payments.with_status(:success).order(:id).last
    if is_regular
      MONTHLY_PRICE * number_of_months
    elsif start_day.to_date <= @billing.prev_expired_at.to_date
      MONTHLY_PRICE * last_regular_payment.number_of_months + \
        price_for_part_of_period(@billing.prev_expired_at.prev_month.next_day.beginning_of_day,
                                 @billing.prev_expired_at.end_of_day, start_day)
    else
      prev_date_arrays = last_regular_payment.periods
      current_period = find_current_period(prev_date_arrays, start_day)
      prev_date_arrays = prev_date_arrays[current_period..(prev_date_arrays.length - 1)]

      (prev_date_arrays.length - 1) * MONTHLY_PRICE + price_for_part_of_period(prev_date_arrays[0][0],
                                                                               prev_date_arrays[0][1],
                                                                               start_day)
    end
  end

  def days_in_period(end_date, start_date)
    (end_date.to_date - start_date.to_date).to_i + 1
  end

  def price_for_part_of_period(period_start, period_end, start_day)
    days_in_period(period_end.to_datetime, start_day) * MONTHLY_PRICE / days_in_period(period_end.to_datetime, period_start.to_datetime)
  end

  def generate_items(licenses_amount, start_day)
    if @promocode.nil?
      cart_item({ standart_fee: @fee_per_new_license, fee_per_license: @fee_per_new_license,
                  licenses_amount: licenses_amount, discount: false,
                  period_start: start_day, period_end: @date_arrays.last[1] })
    elsif licenses_amount > @promocode.number_of_licenses || @date_arrays.length > @promocode.number_of_months
      cart_items(licenses_amount, start_day)
    else
      return @full_discount = true if @promocode.discount == 100
      fee_with_discount = @fee_per_new_license * (100 - @promocode.discount) / 100

      cart_item({ standart_fee: @fee_per_new_license, fee_per_license: fee_with_discount,
                  licenses_amount: licenses_amount, discount: true,
                  period_start: start_day, period_end: @date_arrays.last[1] })
    end
  end

  def cart_item(values)
    @items ||= []
    @amount ||= 0
    @info ||= []
    @info += [{ standart_fee: values[:standart_fee],
                period_start: values[:period_start].to_datetime.strftime('%d %b %Y'),
                period_end: values[:period_end].to_datetime.strftime('%d %b %Y') }]
    period = "#{@info.last[:period_start]}-#{@info.last[:period_end]}"
    name = values[:discount] ? "License with discount #{period}" : "License #{period}"
    @items += [{
      name: name,
      price: values[:fee_per_license] / 100.0,
      currency: 'USD',
      quantity: values[:licenses_amount]
    }]
    @amount += (values[:licenses_amount].to_i * values[:fee_per_license] / 100.0).round(2)
  end

  def cart_items(licenses_amount, start_day)
    if licenses_amount > @promocode.number_of_licenses
      additional_licenses_count = licenses_amount - @promocode.number_of_licenses
      if @date_arrays.length > @promocode.number_of_months
        license_price = ((@promocode.number_of_months - 1) * MONTHLY_PRICE + \
          price_for_part_of_period(@date_arrays[0][0], @date_arrays[0][1], start_day))
        license_price_with_discount = license_price * (100 - @promocode.discount) / 100

        cart_item({ standart_fee: license_price, fee_per_license: license_price_with_discount,
                    licenses_amount: @promocode.number_of_licenses, discount: true,
                    period_start: start_day, period_end: @date_arrays[@promocode.number_of_months - 1][1] })

        license_under_limit_price = MONTHLY_PRICE * (@date_arrays.length - @promocode.number_of_months)

        cart_item({ standart_fee: license_under_limit_price, fee_per_license: license_under_limit_price,
                    licenses_amount: @promocode.number_of_licenses, discount: false,
                    period_start: @date_arrays[@promocode.number_of_months][0], period_end: @date_arrays.last[1] })

        cart_item({ standart_fee: @fee_per_new_license, fee_per_license: @fee_per_new_license,
                    licenses_amount: additional_licenses_count, discount: false,
                    period_start: start_day, period_end: @date_arrays.last[1] })
      else
        license_price_with_discount = @fee_per_new_license * (100 - @promocode.discount) / 100

        cart_item({ standart_fee: @fee_per_new_license, fee_per_license: license_price_with_discount,
                    licenses_amount: @promocode.number_of_licenses, discount: true,
                    period_start: start_day, period_end: @date_arrays[@promocode.number_of_months - 1][1] })

        cart_item({ standart_fee: @fee_per_new_license, fee_per_license: @fee_per_new_license,
                    licenses_amount: additional_licenses_count, discount: false,
                    period_start: start_day, period_end: @date_arrays[@promocode.number_of_months - 1][1] })
      end
    elsif @date_arrays.length > @promocode.number_of_months
      license_price = ((@promocode.number_of_months - 1) * MONTHLY_PRICE + \
          price_for_part_of_period(@date_arrays[0][0], @date_arrays[0][1], start_day))
      license_price_with_discount = license_price * (100 - @promocode.discount) / 100
      license_under_limit_price = MONTHLY_PRICE * (@date_arrays.length - @promocode.number_of_months)

      cart_item({ standart_fee: license_price, fee_per_license: license_price_with_discount,
                  licenses_amount: licenses_amount, discount: true,
                  period_start: start_day, period_end: @date_arrays[@promocode.number_of_months - 1][1] })

      cart_item({ standart_fee: license_under_limit_price, fee_per_license: license_under_limit_price,
                  licenses_amount: licenses_amount, discount: false,
                  period_start: @date_arrays[@promocode.number_of_months][0], period_end: @date_arrays.last[1] })
    end
  end
end
