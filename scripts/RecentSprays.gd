class_name RecentSprays

var spray_queue = []
var spray_queue_mutex = Mutex.new()

func add_spray(stencil:SprayStencil):
	spray_queue_mutex.lock()
	spray_queue.append(stencil)
	spray_queue_mutex.unlock()
