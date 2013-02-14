# Copyright (c) 2012 The Mirah project authors. All Rights Reserved.
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

package org.mirah.jvm.mirrors

import org.jruby.org.objectweb.asm.Opcodes
import org.jruby.org.objectweb.asm.Type
import org.mirah.jvm.types.JVMType
import org.mirah.typer.ResolvedType

class NullType < BaseType
  def initialize
    super('null', Type.getType('Ljava/lang/Object;'), Opcodes.ACC_PUBLIC, nil)
  end
  def widen(other:ResolvedType):ResolvedType
    if other.matchesAnything
      self
    else
      other
    end
  end
  def assignableFrom(other:ResolvedType):boolean
    other.matchesAnything || (other.kind_of?(JVMType) && !JVMType(other).isPrimitive)
  end
end