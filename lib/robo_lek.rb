require "robo_lek/trata_link"
require "robo_lek/trata_produto"
require "robo_lek/crawler"
require "robo_lek/db_mongo"
begin
  require "robo_lek/db_sqlite"
rescue
end
require "robo_lek/db_postgres"
require "robo_lek/pagina"
require "robo_lek/produto"
require "robo_lek/tentaculo"