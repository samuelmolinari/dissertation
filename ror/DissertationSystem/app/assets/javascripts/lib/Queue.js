function Queue() {
	
	var head = null;
	var tail = null;
	
	this.offer = function(e) {
		if(head == null) {
			head = new QueueElement(e);
			tail = head;
		} else {
			tail.nextElement = new QueueElement(e);
			tail = tail.nextElement;
		}
	}
	
	this.peek = function() {
		if(head == null)
			return null;
		
		return head.element;
	}
	
	this.poll = function() {
		
		if(head == null)
			return null;
		
		var r = head.element;
		head = head.nextElement;
		return r;
	}
	
	function QueueElement(elem) {
		this.element = elem;
		this.nextElement = null;
	}
	
}