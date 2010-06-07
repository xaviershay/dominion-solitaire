describe 'a reaction card', :shared => true do
  it 'has a type of :reaction' do
    [*subject[:type]].should include(:reaction)
  end
end
