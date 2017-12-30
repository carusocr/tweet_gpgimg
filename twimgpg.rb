#!/usr/bin/env ruby

=begin

Script that accepts a plain text file and an image file as arguments, then
encrypts the text file with GPG, packages it into the image file, and 
posts the image to the user's Twitter page. 

Future iterations will include an option to simply provide a keyword and
have the imgpg packager perform a Google Image Search for an appropriate
picture and use a random result.

=end

require 'twitter'
require 'gpgme'
require 'yaml'

msg_file = ARGV[0]
img_file = ARGV[1]

class  GPGTweet

  attr_accessor :client

  def initialize(collection = "cace")
    cfgfile = 'auth.yml'
    cnf = YAML::load(File.open(cfgfile))
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key       = cnf[collection]['con_key']
      config.consumer_secret    = cnf[collection]['con_sec']
      config.access_token        = cnf[collection]['o_tok']
      config.access_token_secret = cnf[collection]['o_tok_sec']
    end
  end

  def crypt_msg(msg, recip)
    crypto = GPGME::Crypto.new, :armor => true
    crypto.encrypt msg, recipients: recip, always_trust: true # <--risky? investigate
  end

end
