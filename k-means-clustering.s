#
# IAC 2023/2024 k-means
# 
# Grupo: 57
# Campus: Alameda
#
# Autores:
# 109864, Joana Cardoso
# 110409, Francisco Silva
# 110760, Joao Carvalho
#
# Tecnico/ULisboa

# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:    .zero 120 # 4 vezes n_points
copy_centroids: .zero 24 # 8 vezes k

#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.
                    
.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text

    # Executa a funcao principal do programa
    jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra

### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    # Inicializa as colunas a 0
    li t0, 0
    
    # Repetir 32 vezes cada for
    li t2, 32
    
    # Escolhe a cor
    li a2, white
    
    # Guarda o return adress
    addi sp, sp, -4
    sw ra, 0(sp)

    forCleanScreen1:
        # Inicializa as linhas a 0
        li t1, 0
        
        forCleanScreen2:
            # Coloca as coordenadas como argumentos
            mv a0, t0
            mv a1, t1
            
            # Pinta o ponto de branco
            jal printPoint
            
            # Itera o for2
            addi t1, t1, 1
            bne t1, t2, forCleanScreen2
        
        # Itera o for1    
        addi t0, t0, 1
        bne t0, t2, forCleanScreen1
    
    # Repoe o return adress
    lw ra, 0(sp)
    addi sp, sp, 4
    
    # Volta para o local onde foi chamado
    jr ra

### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    # Carrega o numero de pontos
    mv t0, s3
    
    # Carrega o vetor dos pontos
    mv t1, s4
    
    # Carrega o vetor dos clusters
    mv t2, s6
    
    # Carrega o vetor cores
    mv t3, s7 
    
    # Guarda o return adress
    addi sp, sp, -4
    sw ra, 0(sp)

    forPrintClusters:
        # Carrega as coordenadas do ponto (x-> a0, y-> a1)
        lw a0, 0(t1)
        lw a1, 4(t1)
        
        # Carrega a cor consoante o vetor clusters
        lw t4, 0(t2)
        slli t4, t4, 2
        add t4, t4, t3
        lw a2, 0(t4)
        
        # Pinta o ponto
        jal printPoint
         
        # Aponta para o proximo ponto    
        addi t1, t1, 8
        
        # Aponta para o cluster do proximo ponto     
        addi t2, t2, 4
        
        # Decrementa o contador de pontos
        addi t0, t0, -1
        
        # Se t0 = 0, vai para a etiqueta "fim"
        bnez t0, forPrintClusters
        
    # Repoe o return address
    lw ra, 0(sp)
    addi sp, sp, 4
    
    # Volta para o local onde foi chamado
    jr ra

### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    # Load do vetor de centroides
    mv t0, s2
    
    # Coloca a cor a preto
    li a2, 0
    
    # Guarda o return address
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Inicializa o contador do for
    li t1, 0
    
    # Imprime cada centroide
    forPrintCentroids:
        # Carrega as coordenadas do centroide (x-> a0, y-> a1)
        lw a0, 0(t0)
        lw a1, 4(t0)
        
        # Pinta o ponto
        jal printPoint
        
        # Aponta para o proximo centroide
        addi t0, t0, 8
        
        # Itera o for
        addi t1, t1, 1
        bne t1, s1, forPrintCentroids
    
    # Repoe o return address
    lw ra, 0(sp)
    addi sp, sp, 4
    
    # Volta para o local onde foi chamado 
    jr ra

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual
# de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    # Inicializa o contador do for a 0
    li a4, 0
    
    # Coloca no a6 o vetor centroids
    mv a6, s2
    
    forKiteracoes:
        beq a4, s1, fimKiteracoes

        # Guarda no t0 e t1 as somas dos x e y, inicializadas a 0
        li t0, 0
        li t1, 0
    
        # Conta os pontos de cada cluster
        li t4, 0
    
        # Coloca em t2 o numero de pontos total
        mv t2, s3
    
        # Coloca no t3 o vetor points
        mv t3, s4
    
        # Coloca no a5 o vetor clusters
        mv a5, s6
 
        forCalculateCentroids:
            # Verifica se ja percorreu o vetor points
            beqz t2, fimCalculateCentroids
        
            # Decrementa o contador
            addi t2, t2, -1
            
            # Verifica se o ponto pertence ao cluster a ser calculado
            lw a7, 0(a5)
            bne a4, a7, Incrementa
        
            # Carrega as coordenadas (x-> t5, y-> t6)
            lw t5, 0(t3)
            lw t6, 4(t3)
        
            # Adiciona as coordenadas a soma
            add t0, t0, t5
            add t1, t1, t6
            addi t4, t4, 1
        
            Incrementa:
            # Passa para o ponto seguinte
            addi a5, a5, 4
            addi t3, t3, 8
        
            # Itera o for novamente
            j forCalculateCentroids
        
        fimCalculateCentroids:
            # Evita divisoes por 0 (deixa o centroide na mesma posicao)
            beqz t4, equalZero 
            
            # Calcula a media
            div t0, t0, t4
            div t1, t1, t4
        
            # Guarda as medias no vetor centroids
            sw t0, 0(a6)
            sw t1, 4(a6)
        
            equalZero:
            addi a6, a6, 8
     
            # Volta ao loop
            addi a4, a4, 1
            j forKiteracoes
    
    fimKiteracoes:
    # Volta para o local onde foi chamado
    jr ra

### initializeCentroids
# Inicializa os valores iniciais dos centroides com coordenadas pseudoaleatorias.
# Argumentos: nenhum
# Retorno: nenhum

initializeCentroids:
    # Carrega a base do vetor centroids
    mv t1, s2
    
    # Carrega o valor 32 para o calculo do modulo
    li t6, 32
    
    # Carrega constante que difere os centroides
    li t5, 3986345345
    
    # Gera k coordenadas (x,y) como centroides
    li t3, 0
    forInitialize:
        # Gera coordenadas pseudoaleatorias para x
        li a7, 30
        ecall # a0 fica com o millisegundo atual
        add a0, a0, t5
        remu t4, a0, t6  # x = numero aleatorio % 32
        sw t4, 0(t1)  # Armazena coordenada x no vetor centroids
     
        # Gera coordenadas pseudoaleatorias para y
        li a7, 30
        ecall # a0 fica com o millisegundo atual
        add a0, a0, t5
        mul a0, a0, t4 # multiplica pela coordenada x para aumentar a aleatoriedade
        remu t4, a0, t6  # y = numero aleatorio % 32
        sw t4, 4(t1)  # Armazena coordenada y no vetor centroids
        
        # Passa para o proximo conjunto de coordenadas no vetor centroids
        addi t1, t1, 8
        
        # Muda a constante
        slli t5, t5, 2
        
        # Itera o forInitialize
        addi t3, t3, 1
        bne t3, s1, forInitialize

    # Volta para o local onde foi chamado
    jr ra

### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    # a0 = |x1 - x2| + |y1 - y2|
    # Calcula a diferenca em x
    sub t6, a0, a2
    bgez t6, pos_x
    neg t6, t6
    
    pos_x:
    add a0, t6, zero
    
    # Calcula a diferenca em y
    sub t6, a1, a3
    bgez t6, pos_y
    neg t6, t6
    
    pos_y:
    add a0, a0, t6 
    
    # Volta para o local onde foi chamado
    jr ra

### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # Carrega o numero de clusters (k)
    mv t0, s1

    # Carrega o vetor de centroids
    mv t1, s2 
    
    # t4 tem a distancia menor atual
    li t2, 65  # 65>64 = 32+32: a maior distancia possivel
    
    # t3 tem o indice do cluster mais proximo
    li t3, 0     
    
    # t4 tem o indice do cluster em analise
    li t4, 0
    
    # Guarda o endereco de retorno
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # t5 guarda o x do ponto
    mv t5, a0
    
    forCluster:
        # Carrega as coordenadas do centroide atual (x_centroid, y_centroid)
        lw a2, 0(t1)
        lw a3, 4(t1)

        # Chama a funcao manhattanDistance e guarda a distancia em a0
        jal manhattanDistance
        
        # Verifica se a distancia e a menor
        blt a0, t2, update_cluster
        
        j skip
        
    update_cluster:
        mv t2, a0 #em t2 esta a menor distancia
        mv t3, t4 #em t3 esta o indice do cluster
    
    skip:
        # Repoe o valor de x
        mv a0, t5
        
        # Passa para o proximo centroide
        addi t1, t1, 8
        
        # Incrementa o indice do cluster
        addi t4, t4, 1
        
        # Decrementa o contador de clusters e repete o loop se necessario
        addi t0, t0, -1
        bnez t0, forCluster
        
    # Retorna o indice do cluster mais proximo
    mv a0, t3     
    
    # Volta para o local onde foi chamado
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

### compareCentroids
# Compara dois conjuntos de centroides e terminar o programa
# caso sejam iguais
# Argumentos:
# a2: Centroides antigos
# Retorno: nenhum

compareCentroids:
    # Guarda o valor de 2k em t1
    add t1, s1, s1
    
    # Copia o vetor de centroides atual para t2
    mv t2, s2
    
    # Compara as coordenadas dos centroides antigos e dos atuais
    li t0, 0
    forCompareCentroids:
        lw t4, 0(t2)
        lw t3, 0(a2)
        bne t4, t3, differentCentroids
        
        # Avanca para a proxima coordenada
        addi t2, t2, 4
        addi a2, a2, 4
    
        # Itera o Loop
        addi t0, t0, 1
        bne  t0, t1, forCompareCentroids
        
    # Caso nao haja nenhuma diferenca repoe o endereco de retorno inicial e termina o programa
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
     
    # Volta para o local onde foi chamado    
    differentCentroids:
        jr ra

### copyCentroids
# Copia os centroides atuais para o vetor copy_centroids
# Argumentos: nenhum
# Retorno: nenhum

copyCentroids:
    # Guarda o endereço onde vai criar a copia dos centroides
    la t0 copy_centroids
    
    # Guarda o valor de 2k em t5
    add t5, s1, s1
    
    # Coloca os centroides atuais em t1
    mv t1, s2
    
    # Inicializa o contador
    li t2, 0 
    
    # Copia as coordenadas dos centroides um a um
    forCopyCentroids:
        
        # Load da coordenada atual
        lw t3, 0(t1)
        
        # Store da coordenada no vetor copia
        sw t3, 0(t0)
        
        # Avanca nos vetores de centroides e de copias
        addi t0, t0, 4
        addi t1, t1, 4
        
        # Itera o loop
        addi t2, t2, 1
        bne t2, t5, forCopyCentroids  
        
    # Volta para o local onde foi chamado
    jr ra

### mainKMeans
# Executa o algoritmo k-means.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    # Guarda o endereco de retorno
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Coloca os inputs, os clusters, os centroides e as cores em registos
    lw s1, k
    la s2, centroids
    lw s3, n_points
    la s4, points
    lw s5, L
    la s6, clusters
    la s7, colors

    # Gera k centroides iniciais pseudo-aleatoriamente
    jal initializeCentroids
    
    # Executa L iteracoes do algoritmo
    li s8, 0 # s8 conta de 0 a L
    forMainKMeans1:
         # Limpa o ecra
        jal cleanScreen
        
        # Guarda o endereco do inicio dos vetores de pontos e clusters
        mv s10, s4
        mv s11, s6
        
        # Faz uma copia dos centroides atuais para permitir comparar-los com os novos mais tarde
        jal copyCentroids # OPTIMIZACAO
        
        # Contador de 1 a k
        li s9, 0
        
        # Associa cada ponto a um cluster
        forMainKMeans2:
            # Coloca as coordenadas do ponto no a0 e no a1
            lw a0, 0(s4) # x fica no a0
            lw a1, 4(s4) # y fica no a1
            
            # Encontra o index do cluster ao qual o ponto pertence
            jal nearestCluster
            
            # Guarda o index no vetor clusters
            sw a0, 0(s6)
            addi s6, s6, 4
            
            # Avanca pro proximo ponto
            addi s4, s4, 8
            
            # Itera o for2
            addi s9, s9, 1
            bne s9, s3, forMainKMeans2
        
        # Volta ao inicio dos vetores de clusters e points
        mv s4, s10
        mv s6, s11
        
        
        # Pinta os centroides
        jal printCentroids
    
        # Pinta os clusters
        jal printClusters
        
        # Calcula os centroides dos novos clusters
        jal calculateCentroids
        
        # Pinta os centroides
        jal printCentroids
        
        # Termina o programa caso os centroides se mantenham os mesmos da ultima iteracao
        la a2, copy_centroids # load dos centroides anteriores
        jal compareCentroids # OPTIMIZACAO
        
        # Itera o for1
        addi s8, s8, 1
        bne s8, s5, forMainKMeans1
    
    # Repoe o endereco de retorno
     lw ra, 0(sp)
     addi sp, sp, 4
        
    # Termina o programa
     jr ra
    