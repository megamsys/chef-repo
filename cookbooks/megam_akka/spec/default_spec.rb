require 'chefspec'

describe 'package::install' do
  let(:chef_run) { ChefSpec::Runner.new.converge("megam_akka::default") }

  it 'installs zip unzip' do
    expect(chef_run).to install_package('zip unzip')
    expect(chef_run).to_not install_package('not_zip unzip')
 end
end
