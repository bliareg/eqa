module TestRuns::TestRunResultsHelper
  def thinner_colon
    current_user.locale == 'en' ? 'xs-2' : 'xs-3'
  end

  def wider_colon
    current_user.locale == 'en' ? 'xs-10' : 'xs-9'
  end
end
