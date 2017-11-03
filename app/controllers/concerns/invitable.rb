module Invitable
  extend ActiveSupport::Concern

  def process_invitation(emails)
    if Rails.env.standalone? || Rails.env.development?
      process_invitation_standalone(emails)
    else
      process_invitation_default(emails)
    end
  end

  def process_invitation_default(emails)
    users = User.where(email: emails).group_by(&:email)
    org_members_emails = @organization.members.pluck(:email)
    billing = @organization.owner.billing
    team_emails = @organization.owner.team.pluck(:email)

    flash[:error] = ''
    emails.uniq.each do |email|
      if billing.trial_period? || team_emails.include?(email) || @organization.owner.available_licenses_count > 0
        if email.in?org_members_emails
          flash[:error] += '<br/>' if flash[:error].present?
          flash[:error] += "#{email} #{t('invite.error_1')}"
        else
          if users[email]
            user = users[email].first

            if user.invitation_token.nil?
              UserMailer.send_existing_user_invitation(email,
                                                       params[:message],
                                                       @organization.id)
                        .deliver_later
            else
              UserMailer.send_new_user_invitation(user, params[:message], @organization.id)
                        .deliver_later
            end
          else
            user = create_user_for_invite(email)
            UserMailer.send_new_user_invitation(user, params[:message], @organization.id)
                      .deliver_later
          end

          params_hash = { organization_id: @organization.id,
                          user_id: user.id,
                          role: Role.user_value }
          Role.create!(params_hash) unless Role.where(params_hash).take
          @organization.owner.available_licenses_count -= 1 unless team_emails.include?(email)
        end
      else
        flash[:error] += "<br/>" if flash[:error].present?
        flash[:error] += "#{t('invite.error_2')} #{email}"
      end
    end
    if flash[:error].present?
      flash[:error] = flash[:error].html_safe
      render partial: 'shared/insert_error_message', locals: { partial: 'organizations/invitation_popup' }
    else
      redirect_to organization_profile_members_path(@organization)
    end
  end

  def process_invitation_standalone(emails)
    users = User.where(email: emails).group_by(&:email)
    org_members_emails = @organization.members.pluck(:email)
    team_emails = @organization.owner.team.pluck(:email)

    flash[:error] = ''
    emails.uniq.each do |email|
      if team_emails.include?(email) || @organization.owner.current_license.licenses_left > 0
        if email.in?org_members_emails
          flash[:error] += '<br/>' if flash[:error].present?
          flash[:error] += "#{email} #{t('invite.error_1')}"
        else
          if users[email]
            user = users[email].first

            if user.invitation_token.nil?
              UserMailer.send_existing_user_invitation(email,
                                                       params[:message],
                                                       @organization.id)
                        .deliver_later
            else
              UserMailer.send_new_user_invitation(user, params[:message], @organization.id)
                        .deliver_later
            end
          else
            user = create_user_for_invite(email)
            UserMailer.send_new_user_invitation(user, params[:message], @organization.id)
                      .deliver_later
          end

          params_hash = { organization_id: @organization.id,
                          user_id: user.id,
                          role: Role.user_value }
          Role.create!(params_hash) unless Role.where(params_hash).take
        end
      else
        flash[:error] += "<br/>" if flash[:error].present?
        flash[:error] += "#{t('invite.error_2')} #{email}"
      end
    end
    if flash[:error].present?
      flash[:error] = flash[:error].html_safe
      render partial: 'shared/insert_error_message', locals: { partial: 'organizations/invitation_popup' }
    else
      redirect_to organization_profile_members_path(@organization)
    end
  end
end
