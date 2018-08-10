# require 'spec_helper'
#
# RSpec.describe "handle large file with sed" do
#
#   let(:normal_line_no)  { 124000 }
#   let(:invalid_line_no) { 10 }
#   let(:input_file)      { Tempfile.open('test', '/tmp') }
#
#   before(:each) do
#     begin
#       (1..normal_line_no).each do |i|
#         input_file.puts "\"psmith01\",\"CLASS2B\",\"Peter Smith 1\",\"YEAR2\",\"1\",\"N\",\"ADVANCED\",\"STAFF\",\"1\",\"Y\",\"Y\",\"psmith01\",\"CLASS2B\",\"Peter Smith 1\",\"YEAR2\",\"1\",\"N\",\"ADVANCED\",\"STAFF\",\"1\",\"Y\",\"Y\",\"psmith01\",\"CLASS2B\",\"Peter Smith 1\",\"YEAR2\",\"1\",\"N\",\"ADVANCED\",\"STAFF\",\"1\",\"Y\",\"Y\",\"psmith01\",\"CLASS2B\",\"Peter Smith 1\",\"YEAR2\",\"1\",\"N\",\"ADVANCED\",\"STAFF\",\"1\",\"Y\",\"Y\""
#       end
#       (1..invalid_line_no).each do |i|
#         input_file.puts "@!!@"
#       end
#       input_file.flush
#     ensure
#       input_file.close
#     end
#   end
#
#   after(:each) do
#     input_file.unlink
#   end
#
#   it "should have 124000 lines in output file" do
#     output_path = UnixUtils.sed(input_file.path, ':a', "1,#{invalid_line_no}!{P;N;D;};N;ba")
#     expect(UnixUtils.wc(output_path).first).to eq normal_line_no
#   end
#
# end
