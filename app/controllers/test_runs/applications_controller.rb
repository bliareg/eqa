class TestRuns::ApplicationsController < ApplicationController
  before_action :set_test_run, except: [:show, :destroy]

  private

  def set_test_run
    @test_run = TestRun.find(params[:test_run_id])
  end
end
