guard 'rspec', :version => 2, :all_after_pass => false do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')            { "spec" }
  watch('spec/acceptance_helper.rb')            { "spec" }
  watch(%r{^apps/(.+)\.rb$})              { |m| "spec/apps/#{m[1]}_spec.rb" }
  watch(%r{^models/(.+)/})                { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^helpers/(.+)/})               { |m| "spec/helpers/#{m[1]}_spec.rb" }
  watch('server.rb')                      { "spec/server_spec.rb" }
  watch(%r{^views/(.+)/.*\.(erb|haml)$})  { |m| "spec/requests/#{m[1]}_spec.rb" }
end
