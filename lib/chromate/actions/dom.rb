# frozen_string_literal: true

module Chromate
  module Actions
    module Dom
      def find_element(selector)
        # Récupérer l'ID du document racine
        document = @client.send_message('DOM.getDocument')
        root_id = document['root']['nodeId']

        # Chercher l'élément avec `DOM.querySelector`
        result = @client.send_message('DOM.querySelector', nodeId: root_id, selector: selector)

        raise "Élément non trouvé avec le sélecteur : #{selector}" unless result['nodeId']

        # Obtenir l'objectId pour interagir avec l'élément
        node_info = @client.send_message('DOM.resolveNode', nodeId: result['nodeId'])
        raise "Impossible de résoudre l'élément avec le sélecteur : #{selector}" unless node_info['object']

        node_info['object']['objectId']
      end

      def click_element(selector)
        object_id = find_element(selector)

        # Utiliser `Runtime.callFunctionOn` pour cliquer sur l'élément
        @client.send_message('Runtime.callFunctionOn', functionDeclaration: 'function() { this.click(); }', objectId: object_id)
      end

      def type_text(selector, text)
        object_id = find_element(selector)
        @client.send_message('Runtime.callFunctionOn', functionDeclaration: "function(value) { this.value = value; this.dispatchEvent(new Event('input')); }",
                                                       objectId: object_id, arguments: [{ value: text }])
      end

      def get_text(selector)
        object_id = find_element(selector)
        result = @client.send_message('Runtime.callFunctionOn', functionDeclaration: 'function() { return this.textContent; }', objectId: object_id)
        result['result']['value']
      end

      def get_property(selector, property)
        object_id = find_element(selector)
        result = @client.send_message('Runtime.callFunctionOn', functionDeclaration: "function() { return this['#{property}']; }", objectId: object_id)
        result['result']['value']
      end

      def evaluate_script(script)
        @client.send_message('Runtime.evaluate', expression: script)
      end
    end
  end
end
