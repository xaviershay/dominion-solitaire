describe 'a treasure card', :shared => true do
  it 'has a type of :treasure' do
    subject[:type] == :treasure
  end
end
