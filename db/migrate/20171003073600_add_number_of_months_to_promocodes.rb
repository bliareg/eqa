class AddNumberOfMonthsToPromocodes < ActiveRecord::Migration[5.0]
  def up
    add_column :promocodes, :number_of_months, :integer, default: 1
    add_column :paypal_payments, :base_price, :integer
    add_column :paypal_payments, :periods, :text, array: true, default: []

    execute('UPDATE promocodes SET number_of_months = 1')
    execute('UPDATE paypal_payments SET base_price = 500')

    PaypalPayment.all.each do |pp|
      date_arrays = []
      if pp.regular?
        if pp.period_start.present?
          period_start = pp.period_start
          pp.number_of_months.times do
            date_arrays += [[period_start.beginning_of_day, period_start.next_month.prev_day.end_of_day]]
            period_start += 1.month
          end
          pp.update_attribute(:periods, date_arrays)
        elsif pp == pp.billing.regular_payments.last
          period_start = pp.billing.prev_expired_at.next_day.beginning_of_day
          period_end = pp.billing.expired_at.end_of_day
          pp.number_of_months.times do
            date_arrays += [[period_start.beginning_of_day, period_start.next_month.prev_day.end_of_day]]
            period_start += 1.month
          end
          pp.update_columns(period_start: period_start, period_end: period_end, periods: date_arrays)
        else
          next
        end
      else
        last_regular_payment = PaypalPayment.with_status(:success).where(regular: true, billing_id: pp.billing_id)
                                            .where('paypal_payments.id < ?', pp.id).order(:id).last
        next if last_regular_payment.period_start.nil?
        if pp.period_start.nil?
          pp.update_columns(period_start: pp.created_at.beginning_of_day,
                            period_end: last_regular_payment.period_end.end_of_day)
        end
        if pp.period_start.beginning_of_day < last_regular_payment.period_start.beginning_of_day
          date_arrays += [[last_regular_payment.period_start.prev_month.beginning_of_day, last_regular_payment.period_start.prev_day.end_of_day]]
          date_arrays += last_regular_payment.periods
        else
          date_arrays = last_regular_payment.periods
        end
        pp.update_attribute(:periods, date_arrays)
      end
    end
  end

  def down
    remove_column :promocodes, :number_of_months, :integer
    remove_column :paypal_payments, :periods, :text
  end
end
