# Load the rails application
require File.expand_path('../application', __FILE__)
ActiveSupport::XmlMini.backend = 'LibXML'
# Initialize the rails application
Tolkin::Application.initialize!

#RCC_PUB = 'RECAPTHA KEY GOES HERE'
#RCC_PRIV = 'RECAPTHA KEY GOES HERE'

#require 'will_paginate'
