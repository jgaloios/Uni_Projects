.data
#Nome do ficheiro original
FILENAME:	.asciz "./Desktop/projeto/starwars.rgb"
#Nome do ficheiro output:
OUTPUTFILE:	.asciz "./Desktop/projeto/output.rgb"
#Texto introdutório
INTRODUCAO:	.asciz "Choose a character:\n\n1)Yoda\n2)Darth Maul\n3)Mandalorian\n\n"
#Array com os valores RGB de todos os pixeis da imagem
PIXEIS:		.space 172800
#Array com os valores rgbda imagem output
PIXEISNEW:	.space 172800
#Cores verde ou vermelha 
COR:		.byte 255
#Ausencia de cores
NAOCOR:		.byte 0

.global main

.text
###########################################################################
#Função: read_rgb_image
#Descrição: Lê uma imagem rgb e guarda os seus valores num array de pixeis.
#Arumentos:
# 	a0-nome do ficheiro
# 	a1-Endereço onde o array de valores RGB vai ser guardado
###########################################################################
read_rgb_image:
	li a7,1024	#Código syscall para open
	li a1,0		#flag para leirtura
	ecall
	mv s11,a0
	li a7,63	#Código syscall para Read
	la a1,PIXEIS
	li a2,172800	#tamanho do array (320*180*3)
	ecall
	li a7,57	#Código syscall para Close
	mv a0,s11
	ecall
	jalr zero,0(ra)

#################################################
#Funcao:Hue                                       
#Descricao:  Esta funcao calcula o valor do hue   
#Argumentos:                                      
#	a0 - vermelho                             
#	a1 - verde                                
#	a2 - azul                                 
#Retorna:                                         
#	a0 - hue                                  
#################################################
Hue:	#1º if
	blt a0,a1,ifdois
	blt a1,a2,ifdois
	
	sub a1,a1,a2	#(verde-azul)
	sub a0,a0,a2	#(vermelho-azul)
	slli t0,a1,6	#
	slli t1,a1,2	#60*(verde-azul)
	sub a1,t0,t1	#
	
	div a0,a1,a0
	jalr zero,0(ra)
	
ifdois: blt a1,a0,iftres
	blt a0,a2,iftres
	
	sub a0,a0,a2
	sub a1,a1,a2
	slli t0,a0,6
	slli t1,a0,2
	sub a0,t0,t1
	
	div a0,a0,a1
	li t2,120
	sub a0,t2,a0
	jalr zero,0(ra)
	
iftres: blt a1,a2,ifquatr
	blt a2,a0,ifquatr
	
	sub a2,a2,a0
	sub a1,a1,a0
	slli t0,a2,6
	slli t1,a2,2
	sub a2,t0,t1
	
	div a0,a2,a1
	addi a0,a0,120
	jalr zero,0(ra)
	
ifquatr:blt a2,a1,ifcinco
	blt a1,a0,ifcinco
	
	sub a1,a1,a0
	sub a2,a2,a0
	slli t0,a1,6
	slli t1,a1,2
	sub a1,t0,t1
	
	div a0,a1,a2
	li t2,240
	sub a0,t2,a0
	jalr zero,0(ra)
	
ifcinco:blt a2,a0,ifseis
	blt a0,a1,ifseis
	
	sub a0,a0,a1
	sub a2,a2,a1
	slli t0,a0,6
	slli t1,a0,2
	sub a0,t0,t1
	
	div a0,a0,a2
	addi a0,a0,240
	jalr zero,0(ra)
	
ifseis: blt a0,a2,return
	blt a2,a1,return
	
	sub a2,a2,a1
	sub a0,a0,a1
	slli t0,a2,6
	slli t1,a2,2
	sub a2,t0,t1
	
	div a0,a2,a0
	li t2,320
	sub a0,t2,a0
	jalr zero,0(ra)

return: add a0,zero,zero
	jalr zero,0(ra)
	
##########################################################
#Funcao: Indicator                                       
#Descricao; Esta funcao indica o personagem escolhido   
#Argumentos:                                             
#	a0 - Hue                        
#	a1 - Personagem escolhida                                         
#Retorna:                                                
#	a0 - valor válido                                
##########################################################
indicator:
	li t0,1
	li t1,2
	li t2,3
#Yoda
	bne a1,t0,maul
	li t3,40
	li t4,80
	blt a0,t3,RET
	blt t4,a0,RET
	
	li a0,1
	jalr zero,0(ra)
	   
maul:   bne a1,t1,mando
	li t3,1
	li t4,15
	blt a0,t3,RET
	blt t4,a0,RET
	  
	li a0,1
	jalr zero,0(ra)
     
mando:  bne a1,t2,RET
	li t3,160
	li t4,180
	blt a0,t3,RET
	blt t4,a0,RET
	  
	li a0,1
	jalr zero,0(ra)
	   
RET:	li a0,0
	jalr zero,0(ra)
	
location:

##################################################################
#Funcao: Create_new_array                                      
#Descricao; Esta funcao cria o array com os valores rgb de todos
#	    os pixeis da imagem output pedida no enunciado 
#Argumentos:                                             
#	a0 - array dos pixeis
#	a1 - Cx
#	a2 - Cy  
#	a3 - Escolha da personagem                                                             
#Retorna:                                                
#	a0 - Novo array                               
####################################################################
Create_new_array:
	li t5,1		#Guarda o valor da posição x em t5
	li t6,1		#Guarda o valor da posição y em t6
	addi t0,a1,-5
	addi t1,a1,5
	addi t2,a2,-5
	addi t3,a2,5
	li s2,320
	li s3,180
	la a6,PIXEISNEW
	li s7, 2

wrep:	bgt t6,s3,wend
wX:	bgt t5,s2,wY
	
	blt t5,t0,OR
	blt t1,t5,OR
	bne t6,a2,OR
	beq zero,zero,CRUZ
OR:	blt t6,t2,IMAGEM
	blt t3,t6,IMAGEM
	bne t5,a1,IMAGEM
	
CRUZ:	beq s0,s7,verde
	lbu s8,COR
	lbu s9,NAOCOR
	lbu s10,NAOCOR
	beq zero,zero,OUT
verde:	lbu s8,NAOCOR
	lbu s9,COR
	lbu s10,NAOCOR
	beq zero,zero,OUT
IMAGEM:
	lbu s8,0(a0)
	lbu s9,1(a0)
	lbu s10,2(a0)

OUT:	sb s8,0(a6)
	sb s9,1(a6) 
	sb s10,2(a6)  
	addi a0,a0,3
	addi a6,a6,3
	addi t5,t5,1
	beq zero zero,wX
	
wY:	addi t6,t6,1
	li t5,1
	beq zero,zero,wrep
	
wend:	la a0,PIXEISNEW
	jalr zero,0(ra)
	
##################################################################
#Funcao: Write_rgb_image                                     
#Descricao; Esta funcao cria a imagem pedida no enunciado "output.rgb"
#Argumentos:                                             
#	a0 - array output                                                                                           
####################################################################
Write_rgb_image:
	mv a3,a0
	li a7,1024
	la a0,OUTPUTFILE
	li a1,1
	ecall
	mv s11,a0
	
	li a7,64
	mv a1,a3
	li a2,172800
	ecall
	
	li a7,57
	mv a0,s11
	ecall
	jalr zero,0(ra)
	

main:
	li a7,4		#Código syscall para PrintString
	la a0,INTRODUCAO
	ecall
	
	li a7,5		#Código syscall para ReadInt
	ecall
	
	mv s0,a0	#Guarda a escolha da personagem em s0
	la a0,FILENAME
	la a1,PIXEIS
	jal read_rgb_image
	la s1,PIXEIS	#Guardar o array de pixeis em s1
	
	li s2,320	#Guarda a largura da imagem em s2
	li s3,180	#Guarda a altura da imagem em s3
	li s4,0		#Guarda o somatório do centro de massa de x em s4
	li s5,0		#Guarda o somatório do centro de massa de y em s5
	li s6,0		#Guarda o somatórtio de N em s6
	li t5,1		#Guarda o valor da posição x em t5
	li t6,1		#Guarda o valor da posição y em t6
	
rep:	bgt t6,s3,end
X:	bgt t5,s2,Y
	lbu a0,0(s1)	#Cor vermelha
	lbu a1,1(s1)	#Cor verde
	lbu a2,2(s1)	#Cor azul
	jal Hue
	mv a1,s0
	jal indicator
	
	add s6,s6,a0	#somatório de N
	mul t1,t5,a0	#
	add s4,s4,t1	#somatório de Cx
	mul t1,t6,a0	#
	add s5,s5,t1	#somatório de Cy
	
	addi s1,s1,3
	addi t5,t5,1
	beq zero zero,X
Y:	addi t6,t6,1
	li t5,1
	beq zero,zero,rep
	
end:	div s4,s4,s6	#Guarda o centro de massa de x em s4
	div s5,s5,s6	#Guarda o centro de massa de y em s5
	mv a1,s4
	mv a2,s5
	
	la a0,PIXEIS
	jal Create_new_array
	jal Write_rgb_image
	
