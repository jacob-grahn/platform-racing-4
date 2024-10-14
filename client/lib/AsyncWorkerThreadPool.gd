# Using this while Godot doesn't support non-blocking thread task awaiting
# https://github.com/ctrlraul/AsyncWorkerThreadPool

# MIT License
# 
# Copyright (c) 2024 ctrlraul (Raul Vitor) mailctrlraul@gmail.com
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class_name AsyncWorkerThreadPool

class SignalEmitter:
	signal emitted(result)
	func emit(result = null):
		emitted.emit(result)

static func add_task(callable: Callable, high_priority: bool = false, description: String = ""):
	
	var signal_emitter = SignalEmitter.new()
	
	var wrapper = func():
		var call_result = await callable.call()
		signal_emitter.emit.call_deferred(call_result)
	
	var task_id = WorkerThreadPool.add_task(wrapper, high_priority, description)
	
	var result = await signal_emitter.emitted
	
	WorkerThreadPool.wait_for_task_completion(task_id)
	
	return result

static func add_group_task(callable: Callable, elements: int, tasks_needed: int = -1, high_priority: bool = false, description: String = ""):
	
	var signal_emitter = SignalEmitter.new()
	var results = []
	var tasks_remaining = { "count": elements }
	
	results.resize(elements)
	
	var wrapper = func(element: int):
		results[element] = await callable.call(element)
		tasks_remaining.count -= 1
		if tasks_remaining.count == 0:
			signal_emitter.emit.call_deferred()
	
	var group_id = WorkerThreadPool.add_group_task(wrapper, elements, tasks_needed, high_priority, description)
	
	await signal_emitter.emitted
	
	WorkerThreadPool.wait_for_group_task_completion(group_id)
	
	return results
