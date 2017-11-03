require 'rails_helper'

RSpec.describe ColumnSet, type: :model do
  let(:test_case_columns) { TestCase::VISIBLE_COLUMNS.keys }
  let(:test_run_result_columns) { TestRunResult::VISIBLE_COLUMNS.keys }

  it '.generate_default generates 2 default ColumnSet instances for TestRunResult and TestCase' do
    ColumnSet.generate_default
    expect(ColumnSet.count).to be 2
    expect(ColumnSet.any? { |set| set.names == test_run_result_columns }).to be_truthy
    expect(ColumnSet.any? { |set| set.names == test_case_columns }).to be_truthy
  end

  describe '.default_for' do
    before(:each) { ColumnSet.generate_default }

    context 'passed TestRun' do
      it 'returns default column set for test runs' do
        col_set = ColumnSet.default_for(TestRun)
        expect(col_set.names).to eq test_run_result_columns
      end
    end

    context 'passed TestPlan' do
      it 'returns default column set for test plans' do
        col_set = ColumnSet.default_for(TestPlan)
        expect(col_set.names).to eq test_case_columns
      end
    end
  end
end
