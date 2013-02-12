# module ActiveRecord
#   module ConnectionAdapters
#     module QueryCache
#       def select_all(*args)
#         sql = args.first
#         debugger if sql.match(/SELECT/)
#         if @query_cache_enabled
#           cache_sql(args.first) { super }
#         else
#           super
#         end
#       end
#     end
#   end
# end
