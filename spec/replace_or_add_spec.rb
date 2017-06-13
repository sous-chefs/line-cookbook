#
# Cookbook Name:: line
#
# Copyright 2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rspec_helper'
require 'stringio'

describe 'replace_or_add lines in an existing file' do
  let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04', step_into: ['replace_or_add']) }

  let(:testfile) do
    'Data line
    Alt data line extended
    Third line
    Identical line
    Identical line
    Penultimate
    Last line'.gsub!(/^\s+/, '')
  end

  let(:testfile_size) { testfile.lines.count }

  before do
    @temp_file = Tempfile.new('foo')
    @file_content = testfile
    file_replacement
  end

  context 'when the pattern does not match the replacement line' do
    describe 'replacement line matches a line in the middle a file' do
      before { chef_run.converge('line_tests::replace_or_add_line_present_in_middle') }
      it 'does not add extra lines' do
        expect(@file_content.scan(/^Penultimate$/).size).to eq(1)
      end
      it 'does not change the file size' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'is idempotent' do
        expect(chef_run).to edit_replace_or_add('line_present_in_middle').with(updated_by_last_action?: false)
      end
    end

    describe 'replacement line matches the final line' do
      before { chef_run.converge('line_tests::replace_or_add_line_present_at_end') }
      it 'does not add extra lines' do
        expect(@file_content.scan(/^Last line$/).size).to eq(1)
      end
      it 'does not change the file size' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'is idempotent' do
        expect(chef_run).to edit_replace_or_add('line_present_at_end').with(updated_by_last_action?: false)
      end
    end

    describe 'search does not match the file' do
      before { chef_run.converge('line_tests::replace_or_add_unmatched_line') }
      it 'should add line contents' do
        expect(@file_content.scan(/^Unmatched line$/).size).to eq(1)
      end
      it 'should add one line' do
        expect(@file_content.lines.count).to eq(testfile_size + 1)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('unmatched_line').with(updated_by_last_action?: true)
      end
    end

    describe 'pattern matches a line' do
      before { chef_run.converge('line_tests::replace_or_add_match_third_line') }
      it 'should replace a line' do
        expect(@file_content.scan(/^Different replacement$/).size).to eq(1)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('match_third_line').with(updated_by_last_action?: true)
      end
    end
  end

  context 'when the pattern does match the replacement line' do
    describe 'search does not match the file' do
      before { chef_run.converge('line_tests::replace_or_add_another_line_matching_pattern') }
      it 'should add the right line' do
        expect(@file_content.scan(/^Add another line$/).size).to eq(1)
      end
      it 'should add one line' do
        expect(@file_content.lines.count).to eq(testfile_size + 1)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('another_line_matching_pattern').with(updated_by_last_action?: true)
      end
    end

    describe 'search matches a line' do
      before { chef_run.converge('line_tests::replace_or_add_middle_match') }
      it 'should add the right line' do
        expect(@file_content.scan(/^data line extended$/).size).to eq(1)
      end
      it 'should delete the original line' do
        expect(@file_content).not_to match(/Alt data line extended/)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('middle_match').with(updated_by_last_action?: true)
      end
    end

    describe 'search matches when the pattern anchors the line start' do
      before { chef_run.converge('line_tests::replace_or_add_start_of_line_match') }
      it 'should change a line correctly' do
        expect(@file_content.scan(/^Data line longer and longer$/).size).to eq(1)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('start_of_line_match').with(updated_by_last_action?: true)
      end
    end

    describe 'when pattern matches and the last line does not end in \n' do
      before { chef_run.converge('line_tests::replace_or_add_change_line_eof') }
      it 'should change the line' do
        expect(@file_content.scan(/^Last line changed$/).size).to eq(1)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('change_line_eof').with(updated_by_last_action?: true)
      end
    end

    describe 'when line matches and the last line does not end in \n' do
      before { chef_run.converge('line_tests::replace_or_add_line_eof') }
      it 'should not change the line' do
        expect(@file_content.scan(/^Last line$/).size).to eq(1)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should be idempotent' do
        expect(chef_run).to edit_replace_or_add('line_eof').with(updated_by_last_action?: false)
      end
    end

    describe 'when line matchs in the middle of a file' do
      before { chef_run.converge('line_tests::replace_or_add_line_mid_file') }
      it 'should not change the line' do
        expect(@file_content.scan(/^Third line$/).size).to eq(1)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('line_mid_file').with(updated_by_last_action?: false)
      end
    end

    describe 'when multiple lines match' do
      before { chef_run.converge('line_tests::replace_or_add_duplicate') }
      it 'should change both lines' do
        expect(@file_content.scan(/^Replace duplicate lines$/).size).to eq(2)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('duplicate').with(updated_by_last_action?: true)
      end
    end
  end

  context 'when replace_only is specified' do
    describe 'when lines match' do
      before { chef_run.converge('line_tests::replace_or_add_replace_only_match') }
      it 'should change both lines' do
        expect(@file_content.scan(/^Replace duplicate lines$/).size).to eq(2)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should flag the resource change' do
        expect(chef_run).to edit_replace_or_add('replace_only').with(updated_by_last_action?: true)
      end
    end

    describe 'when no lines match' do
      before { chef_run.converge('line_tests::replace_or_add_replace_only_nomatch') }
      it 'should change no lines' do
        expect(@file_content.scan(/^Replace duplicate lines$/).size).to eq(0)
      end
      it 'should not add lines' do
        expect(@file_content.lines.count).to eq(testfile_size)
      end
      it 'should not flag the resource change' do
        expect(chef_run).to edit_replace_or_add('replace_only_no_match').with(updated_by_last_action?: false)
      end
    end
  end
end

# describe 'replace_or_add lines in a missing file' do
#   let(:chef_run) do
#     ChefSpec::SoloRunner.new(step_into: ['replace_or_add'])
#   end
#
#   before(:each) do
#     @temp_file = Tempfile.new('foo')
#     @file_content = ''
#     file_replacement
#   end
#
#   context 'when the pattern does not match the replacement line' do
#     before {  chef_run.converge('line_tests::replace_or_add_missing_00') }
#     it 'should add a line' do
#       expect(@file_content.scan(/^add this line$/).size).to eq(1)
#     end
#     it 'should flag the resource change' do
#       expect(chef_run).to edit_replace_or_add('missing_file').with(updated_by_last_action?: true)
#     end
#   end
#
#   context 'when the pattern matches the replacement line' do
#     before { chef_run.converge('line_tests::replace_or_add_missing_01') }
#     it 'should add a line' do
#       expect(@file_content.scan(/^add this line$/).size).to eq(1)
#     end
#     it 'should flag the resource change' do
#       expect(chef_run).to edit_replace_or_add('missing_file').with(updated_by_last_action?: true)
#     end
#   end
#
#   context 'when replace_only is true' do
#     before { chef_run.converge('line_tests::replace_or_add_missing_02') }
#     it 'should not add a line' do
#       expect(@file_content.scan(/^add this line$/).size).to eq(0)
#     end
#     it 'should flag the resource change' do
#       expect(chef_run).to edit_replace_or_add('missing_file').with(updated_by_last_action?: false)
#     end
#   end
# end

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
