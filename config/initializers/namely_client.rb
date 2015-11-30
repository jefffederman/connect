Namely::ResourceGateway # Poke the constant to make sure we're not defining from scratch

module Namely
  class ResourceGateway
    def json_index_paged
      Enumerator.new do |y|
        params = { profile_format: 'full' }

        loop do
          objects = get("/#{endpoint}", params)[resource_name]
          break if objects.empty?

          objects.each { |o| y << o }

          params[:after] = objects.last["id"]
        end
      end
    end
  end
end
