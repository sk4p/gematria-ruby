# -*- coding: utf-8 -*- 
#

def getConnectInfo
  JSON.parse(File.read('/home/gematria/db.json'))
end

def connectDB
  info = getConnectInfo()
  $db = 
    Mysql2::Client.new(:host => info['host'],
                       :username => info['username'],
                       :database => info['database'],
                       :password => info['password'])
  rs = $db.query('SET NAMES utf8')
end

