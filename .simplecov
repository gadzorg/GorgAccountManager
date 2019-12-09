SimpleCov.start 'rails' do
  # any custom configs like groups and filters can be here at a central place
  add_filter "/module/merge"
  add_filter "platal"
end if ENV["NO_COVERAGE"].nil?
