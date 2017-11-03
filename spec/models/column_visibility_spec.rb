require 'rails_helper'

RSpec.describe ColumnVisibility, type: :model do

    before :each do
      ColumnSet.generate_default
      @visibility = create(:column_visibility,
                          column_set: ColumnSet.default_for(TestPlan))
    end

    describe '#set_correct_column_set' do
      context 'pass value that column_visibility already contains' do
        it 'don\'t updates column_set' do
          column_names = @visibility.column_set.names
          before_update_count = ColumnSet.count
          @visibility.set_correct_column_set(column_names)
          expect(before_update_count).to be ColumnSet.count
        end
      end
      context 'pass different value' do
        it 'create new column_set and assigne it' do
          column_names = @visibility.column_set.names
          2.times { column_names.pop }
          before_update_count = ColumnSet.count
          @visibility.set_correct_column_set(column_names)
          expect(before_update_count).not_to be ColumnSet.count
        end
      end
    end
end
