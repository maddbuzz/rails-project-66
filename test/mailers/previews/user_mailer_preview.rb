# frozen_string_literal: true

# Preview all emails at http://127.0.0.1:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def repo_check_failed
    UserMailer.with(check: Repository::Check.first).repo_check_failed
  end

  def repo_check_verification_failed
    UserMailer.with(check: Repository::Check.last).repo_check_verification_failed
  end
end
