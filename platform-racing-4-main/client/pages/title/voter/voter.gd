extends Node2D

var request_is_pending = false
var answers: Dictionary
var question: String


func _ready():
	$HTTPRequest.request_completed.connect(self._http_request_completed)


func init(p_question: String, answers_array: Array):
	question = p_question
	var error = $HTTPRequest.request(ApiManager.get_base_url() + "/results?question=" + question.uri_encode())
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	else:
		request_is_pending = true
		
	# set up a dict of answers
	var i:int = 0
	for answer in answers_array:
		var node = get_node("Answer" + str(i))
		answers[answer] = {
			"answer": answer,
			"votes": 0,
			"node": node
		}
		node.get_node("Label").text = answer
		node.get_node("Votes").text = '...'
		node.get_node("Button").pressed.connect(_on_voted.bind(answer))
		i += 1


func _http_request_completed(result, response_code, headers, body):
	request_is_pending = false
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if !response:
		return
	if response.get("error", ''):
		return
	for answer_str in response.answers:
		var answer = answers.get(answer_str, null)
		if !answer:
			continue
		answer.node.get_node("Votes").text = "Votes: " + str(response.answers[answer_str])
		print(answer)


func _on_voted(answer_str: String):
	if request_is_pending:
		return
	
	# Send vote
	var body = JSON.new().stringify({"question": question, "answer": answer_str})
	var error = $HTTPRequest.request(ApiManager.get_base_url() + "/vote", [], HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred sending vote request.")
	else:
		request_is_pending = true
