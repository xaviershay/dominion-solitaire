describe 'an attack card', :shared => true do
  it 'has a type of :attack' do
    [*subject[:type]].should include(:attack)
  end
end
