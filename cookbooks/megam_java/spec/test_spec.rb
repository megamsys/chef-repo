require 'chefspec'

describe 'package::remove' do
  let(:chef_run) { ChefSpec::Runner.new.converge("megam_java::test") }

  it 'removes a package with an explicit action' do
    expect(chef_run).to remove_package('explcit')
    expect(chef_run).to_not remove_package('not_explicit')
  end

  it 'removes a package with attributes' do
    expect(chef_run).to remove_package('with_attributes').with(version: '1.0.0')
    expect(chef_run).to_not remove_package('with_attributes').with(version: '1.2.3')
  end

  it 'removes a package when specifying the identity attribute' do
    expect(chef_run).to remove_package('identity_attribute')
  end
end
