# frozen_string_literal: true

require 'websocket-client-simple'

module Chromate
  class Client
    attr_reader :port, :ws

    def initialize(options = {})
      @port = options[:port] || find_available_port
    end

    def start
      @ws_url = fetch_websocket_debug_url
      @ws = WebSocket::Client::Simple.connect(@ws_url)
      @id = 0
      @callbacks = {}

      client_self = self

      @ws.on :message do |msg|
        client_self.handle_message(JSON.parse(msg.data))
      end

      @ws.on :open do
        puts "Connexion WebSocket établie avec #{@ws_url}"
      end

      @ws.on :error do |e|
        puts "Erreur WebSocket : #{e.message}"
      end

      @ws.on :close do |_e|
        puts 'Connexion WebSocket fermée'
      end

      sleep 0.2
      client_self.send_message('Target.setDiscoverTargets', { discover: true })
      client_self
    end

    def send_message(method, params = {})
      @id += 1
      message = { id: @id, method: method, params: params }
      puts "Envoi du message : #{message}"

      begin
        @ws.send(message.to_json)
        @callbacks[@id] = Queue.new
        result = @callbacks[@id].pop
        puts "Réponse reçue pour le message #{message[:id]} : #{result}"
        result
      rescue StandardError => e
        puts "Erreur WebSocket lors de l'envoi du message : #{e.message}"
        reconnect
        retry
      end
    end

    def reconnect
      @ws_url = fetch_websocket_debug_url
      @ws     = WebSocket::Client::Simple.connect(@ws_url)
      puts 'Reconnexion WebSocket réussie'
    end

    def close
      @ws&.close
    end

    def handle_message(message)
      puts "Message reçu : #{message}"
      return unless message['id'] && @callbacks[message['id']]

      @callbacks[message['id']].push(message['result'])
      @callbacks.delete(message['id'])
    end

    def fetch_websocket_debug_url
      # Récupérer la liste des cibles disponibles
      uri = URI("http://localhost:#{@port}/json/list")
      response = Net::HTTP.get(uri)
      targets = JSON.parse(response)

      # Trouver une cible de type 'page'
      page_target = targets.find { |target| target['type'] == 'page' }

      if page_target
        page_target['webSocketDebuggerUrl']
      else
        # Créer une nouvelle cible de page si aucune n'est disponible
        create_new_page_target
      end
    end

    def create_new_page_target
      # Créer une nouvelle page
      uri = URI("http://localhost:#{@port}/json/new")
      response = Net::HTTP.get(uri)
      new_target = JSON.parse(response)

      # Retourner l'URL WebSocket de la nouvelle page
      new_target['webSocketDebuggerUrl']
    end

    def find_available_port
      server = TCPServer.new('127.0.0.1', 0)
      port = server.addr[1]
      server.close
      port
    end
  end
end
