require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/table'

module Cucumber
  module Ast
    describe Table do
      before do
        @table = Table.new([
          %w{one four seven},
          %w{4444 55555 666666}
        ])
        @table.extend(Module.new{
          attr_reader :raw
        })
        def @table.cells_rows; super; end
        def @table.columns; super; end
      end

      it "should have rows" do
        @table.cells_rows[0].map{|cell| cell.value}.should == %w{one four seven}
      end

      it "should have columns" do
        @table.columns[1].map{|cell| cell.value}.should == %w{four 55555}
      end

      it "should have same cell objects in rows and columns" do
        # 666666
        @table.cells_rows[1].__send__(:[], 2).should equal(@table.columns[2].__send__(:[], 1))
      end

      it "should know about max width of a row" do
        @table.columns[1].__send__(:width).should == 5
      end

      it "should be convertible to an array of hashes" do
        @table.hashes.should == [
          {'one' => '4444', 'four' => '55555', 'seven' => '666666'}
        ]
      end

      it "should accept symbols as keys for the hashes" do
        @table.hashes.first[:one].should == '4444'
      end

      it "should allow map'ing columns" do
        @table.map_column('one') { |v| v.to_i }
        @table.hashes.first['one'].should == 4444
      end

      it "should fail silently if a map'd column does not exist" do
        lambda {
          @table.map_column('two') { |v| v.to_i }
        }.should_not raise_error
      end

      describe "replacing arguments" do

        before(:each) do
          @table = table = Table.new([
            %w{qty book},
            %w{<qty> <book>}
            ])
        end

        it "should return a new table with arguments replaced with values" do
          table_with_replaced_args = @table.arguments_replaced({'<book>' => 'Unbearable lightness of being', '<qty>' => '5'})

          table_with_replaced_args.hashes[0]['book'].should == 'Unbearable lightness of being'
          table_with_replaced_args.hashes[0]['qty'].should == '5'
        end

        it "should replace nil values with nil" do
          table_with_replaced_args = @table.arguments_replaced({'<book>' => nil})

          table_with_replaced_args.hashes[0]['book'].should == nil
        end

        it "should not change the original table" do
          table_with_replaced_args = @table.arguments_replaced({'<book>' => 'Unbearable lightness of being'})

          @table.hashes[0]['book'].should_not == 'Unbearable lightness of being'
        end

      end
      
      it "should convert to sexp" do
        @table.to_sexp.should == 
          [:table, 
            [:row, 
              [:cell, "one"], 
              [:cell, "four"],
              [:cell, "seven"]
            ],
            [:row, 
              [:cell, "4444"], 
              [:cell, "55555"],
              [:cell, "666666"]]]
      end
    end
  end
end
