# Copyright (c) 2010 The Mirah project authors. All Rights Reserved.
# All contributing project authors may be found in the NOTICE file.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Mirah
  module Util
    module ProcessErrors
      java_import 'org.mirah.typer.ErrorType'

      # errors - array of NodeErrors
      def process_errors(errors)
        errors.each do |ex|
          if ex.kind_of?(ErrorType)
            ex.messages.each do |error_message|
              message, position = error_message.message, error_message.position
              if position
                Mirah.print_error(message, position)
              else
                puts message
              end
            end if ex.messages
          else
            puts ex
            if ex.respond_to?(:node) && ex.node
              Mirah.print_error(ex.messages.first, ex.position)
            else
              puts ex.messages
            end
            error(ex.backtrace.join("\n")) if self.logging?
          end
        end
        throw :exit, 1 unless errors.empty?
      end

      java_import 'mirah.lang.ast.NodeScanner'
      class ErrorCollector < NodeScanner
        def initialize(typer)
          super()
          @errors = {}
          @typer = typer
        end
        def exitDefault(node, arg)
          type = @typer.getResolvedType(node)
          if (type && type.isError)
            @errors[type] ||= begin
              case type.messages.size
              when 1
                m = type.messages[0]
                #if !m.has_position?
                #  m.position = node rescue nil
                #elsif m.size == 2 && m[1] == nil
                #  m[1] = node.position rescue nil
                #end
                if !m.has_position?
                  m.position = node.position rescue nil
                end
              when 0
                type.messages << ["Error", node.position]
              else
                # pass
              end
              type
            end
          end
          nil
        end
        def errors
          @errors.values
        end
      end

      def process_inference_errors(typer, nodes)
        errors = []
        nodes.each do |ast|
          collector = ErrorCollector.new(typer)
          ast.accept(collector, nil)
          errors.concat(collector.errors)
        end
        failed = !errors.empty?
        if failed
          if block_given?
            yield(errors)
          else
            puts "Inference Error:"
            process_errors(errors)
          end
        end
      end

    end
  end
end
