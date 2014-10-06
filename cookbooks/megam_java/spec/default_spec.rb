require 'chefspec'

describe 'package::install' do
  let(:chef_run) { ChefSpec::Runner.new.converge("megam_java::default") }

  it 'installs openjdk-7-jdk' do
    expect(chef_run).to install_package('openjdk-7-jdk')
    expect(chef_run).to_not install_package('not_openjdk-7-jdk')
 end

it 'installs openjdk-7-jre' do
    expect(chef_run).to install_package('openjdk-7-jre')
    expect(chef_run).to_not install_package('not_openjdk-7-jre')
 end
end

