extends Node2D

# guarda as questoes ja embaralhadas em
# numero igual ao de decks
var rand_questions={}
var quesitos={}
var respostas={}

var score_certos = 0 
var score_errados = 0
var total_score = 0
var total_tentativas = 0

var q_clicked = {} # pergunta clickada
var r_clicked = {} # resposta clickada
var deck_q_clicked = 0
var deck_r_clicked = 0

var PERGS = 0 # numero de perguntas no json
var DECKS = 0 # numero de cartas

const INIT     = 0
const BEGIN    = 1
const RUN      = 2
const PAUSED   = 3
const FINISHED = 4

var game_status = INIT

func _ready():
	qa.prepare()
	init_panel()
	PERGS=qa.qa.size()
	DECKS=get_node("Container/Respostas").get_child_count()
	print("Total de perguntas carregadas: " + str(PERGS))
	print ("Total de decks encontrados: " + str(DECKS))
	init_deck()
	game_status = BEGIN
	
func init_panel():
	if (game_status == RUN):
		get_node("Container/Respostas").hide()
		get_node("Container/Perguntas").show()
		get_node("Container/lbl_reposta").hide()
		get_node("Container/lbl_pergunta").hide()
		get_node("certo").hide()
		get_node("errado").hide()
	if (game_status == BEGIN): 
		get_node("Container/Respostas").show()
		get_node("Container/Perguntas").show()
		get_node("Container/lbl_reposta").hide()
		get_node("Container/lbl_pergunta").hide()
		get_node("certo").show()
		get_node("errado").show()	
	
func on_b_pergunta_pressed(obj,pai):
	if (game_status != RUN): return
	get_node("Container/Perguntas").hide()
	get_node("Container/Respostas").show()
	deck_q_clicked = str(obj)
	var x = str(obj).right(5)
	get_node("Container/lbl_pergunta").set_text(quesitos[int(x)]['q'])
	q_clicked = quesitos[int(x)]
	get_node("Container/lbl_pergunta").show()

func on_b_resposta_pressed(obj,pai):
	if (game_status != RUN): return
	get_node("Container/Respostas").hide()
	deck_r_clicked = str(obj)
	var x = str(obj).right(5)
	get_node("Container/lbl_reposta").set_text(respostas[int(x)]['r'])
	r_clicked = respostas[int(x)]
	get_node("Container/lbl_reposta").show()
	get_node("certo").show()
	get_node("errado").show()

func _on_ajuda_pressed():
	game_status = PAUSED
	get_node("/root/jogo/Popups/dlghelp").show()

func _on_certo_pressed():
	if (game_status != RUN): return
	total_tentativas += 1
	if (q_clicked == r_clicked):
		score_certos += 1
		get_node("Container/Perguntas/"+deck_q_clicked).hide()
		get_node("Container/Respostas/"+deck_r_clicked).hide()
	else:
		score_errados += 1
	refresh_label()
	init_panel()
	check_and_end()

func _on_errado_pressed():
	if (game_status != RUN): return
	total_tentativas += 1
	if (q_clicked == r_clicked):
		score_errados += 1
	refresh_label()
	init_panel()
	check_and_end()
	
func refresh_label():
	if (game_status != RUN): return
	get_node("placar").set_text('Acertos: '+str(score_certos)+ \
	  ' Erros: ' + str(score_errados) + \
	  ' Tentativas: ' + str(total_tentativas))	
	
func check_and_end():
	if score_certos == DECKS:
		game_status = FINISHED
		total_score = total_tentativas + score_errados
		var metrica = DECKS/sqrt(int(get_node("tempo").get_text()))
		total_score = int(10*(total_score + metrica))
		get_node("placar").set_text('Pontos Totais:' + str(total_score))
		get_node("Timer").stop()
		get_node("playbutton").set_disabled(false)
		get_node("playbutton").show()
	
func _on_playbutton_pressed():
	print("Play!")
	if (game_status == RUN): return
	game_status = RUN
	total_score = 0
	score_certos = 0
	score_errados = 0
	total_tentativas = 0
	get_node("placar").set_text('Pontos Totais:' + str(total_score))
	get_node("playbutton").set_disabled(true)
	get_node("playbutton").hide()
	get_node("Timer").start()
	init_panel()

func _on_Timer_timeout():
# atualiza o contador de tempo de jogo
	if (game_status != RUN): return
	var novo_tempo = int(get_node("tempo").get_text()) + 1
	get_node("tempo").set_text(str(novo_tempo))

func _on_dlghelp_confirmed():
	game_status = RUN

func init_deck():
# sorteia as perguntas existentes por quantos cartas tiverem
# ou seja, pode ter menos perguntas que cartas e podem ter perguntas repetidas
	# nao permite repetir QR's:
	var done={}
	if (PERGS >= DECKS):
		for i in range(DECKS):
			while(true):
				randomize()
				var rand = floor(rand_range(0, PERGS)) + 1
				if done.has(str(rand)): continue
				rand_questions[i+1] = qa.qa[str(rand)]
				done[str(rand)]=i+1
				#print ("Saiu rand: " + str(rand))
				break
	# permite QR's duplicadas por falta de perguntas
	else:
		for i in range(DECKS):
			randomize()
			var rand = floor(rand_range(0,PERGS)) + 1
			rand_questions[i+1] = qa.qa[str(rand)]

	# separa as perguntas das respostas
	# para cada deck ficar com uma ordem aleatoria
	done={}
	for i in range(DECKS):
		while(true):
			randomize()
			var rand_n = floor(rand_range(0, DECKS)) + 1
			if done.has(str(rand_n)): continue
			quesitos[i+1] = rand_questions[int(rand_n)]
			done[str(rand_n)]= i+1
			break
	done={}
	for i in range(DECKS):
		while(true):
			randomize()
			var rand_n = floor(rand_range(0, DECKS)) + 1
			if done.has(str(rand_n)): continue
			respostas[i+1] = rand_questions[int(rand_n)]
			done[str(rand_n)] = i+1
			break