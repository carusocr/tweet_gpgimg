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
recip = ARGV[1]
img_file = ARGV[2]

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
    crypto = GPGME::Crypto.new(armor: true, always_trust: true) # risky? doesn't work without...
    crypto.encrypt msg, recipients: recip
  end

  def package_msg(msg, img_file)
    img_ext = File.extname(img_file)
    # output encrypted message to tmpfile
    File.open('tmpfile','w') {|f| f.puts msg}
    # run 'zip msg.zip tmpfile'
    `zip msg.zip tmpfile`
    # cat imagefile.jpg msg.zip > newimage.jpg
    newimg = "newimg" + img_ext
    `cat #{img_file} msg.zip > #{newimg}`
    # remove msg.zip and tmpfile
    return newimg
  end

  def post_img_tweet(img_file)
    @client.update_with_media("Testing twgpgimg!", File.new(img_file))
  end

end

msg_text = File.read(msg_file)
c = GPGTweet.new
msg = c.crypt_msg(msg_text, recip).to_s
newimg = c.package_msg(msg, img_file)
c.post_img_tweet(newimg)
