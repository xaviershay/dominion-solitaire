describe 'a victory card', :shared => true do
  it 'has a type of :victory' do
    [*subject[:type]].should include(:victory)
  end
end
