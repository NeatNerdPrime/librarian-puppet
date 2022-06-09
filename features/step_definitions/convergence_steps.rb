Then /^the file "([^"]*)" should have an inode and ctime$/ do |file|
    cd('.') do
        stat = File.stat(File.expand_path(file))
        @before_inode = { 'ino' => stat.ino, 'ctime' => stat.ctime }
        expect(@before_inode['ino']).not_to eq nil
        expect(@before_inode['ctime']).not_to eq nil
    end
end

Then /^the file "([^"]*)" should have the same inode and ctime as before$/ do |file|
    cd('.') do
        stat = File.stat(File.expand_path(file))
        expect(stat.ino).to eq @before_inode['ino']
        expect(stat.ctime).to eq @before_inode['ctime']
    end
end

Then /^the file "([^"]*)" should not have the same inode or ctime as before$/ do |file|
    cd('.') do
        stat = File.stat(File.expand_path(file))

        begin
            expect(stat.ino).not_to eq @before_inode['ino']
        rescue RSpec::Expectations::ExpectationNotMetError
            expect(stat.ctime).not_to eq @before_inode['ctime']
        end
    end
end

Then /^the git revision of module "([^"]*)" should be "([0-9a-f]*)"$/ do |module_name, rev|
    cd("modules/#{module_name}") do
      cmd = "git rev-parse HEAD"
      run_command_and_stop(cmd)
      expect(last_command_started.output.strip).to eq(rev)
    end
end

Given /^I wait for (\d+) seconds?$/ do |n|
  sleep(n.to_i)
end
