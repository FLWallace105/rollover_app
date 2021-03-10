# this is a config file to get resque to work https://gist.github.com/snatchev/131647

require 'resque/tasks'

task "resque:setup" => :environment do
    ENV['QUEUE'] ||= '*'
    puts "The current environment is: #{Rails.env}"
end