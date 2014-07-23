#!/usr/bin/env ruby

require 'bundler/setup'

require 'em-websocket'
require 'json'
require 'ostruct'

require_relative 'dispatcher.rb'
require_relative 'user.rb'

$stdout.sync = true

puts "ReactiveServer is starting up ..."

EM.run do
    @clients = {}

    EM::WebSocket.run(:host => "127.0.0.1", :port => 8080) do |ws|
        include Logging

        ws.onopen do |handshake|
            logger.info("User #{ws.hash} has connected")
            logger.debug(handshake.headers["User-Agent"])
            @clients[ws] = User.new ws
        end

        ws.onclose do
            logger.info("User #{ws.hash} has disconnected")
            @clients[ws].uninitialize
            @clients.delete(ws)
        end

        ws.onmessage do |msg|
            logger.info("User #{ws.hash} sent message")
            begin
                message = OpenStruct.new JSON.parse(msg)
                Dispatcher.dispatch(@clients[ws], message)
            rescue Exception => e
                logger.error("User #{ws.hash} sent invalid message and caused error: #{e}")
                ws.send({:topic => "error", :data => e}.to_json)
            end
        end
    end
end
