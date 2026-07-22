## R0 — Baseline convencional

A estrutura R0 foi implementada em C para o Vitis HLS utilizando a multiplicação complexa convencional com quatro produtos reais explícitos:

P0 = Br·Wr
P1 = Bi·Wi
P2 = Br·Wi
P3 = Bi·Wr

Tr = P0 - P1
Ti = P2 + P3

Cr = Ar + Tr
Dr = Ar - Tr
Ci = Ai + Ti
Di = Ai - Ti

Foram avaliadas três formas de descrever a mesma R0 em C: uma versão com expressões compactas, uma versão com intermediários explícitos em 16 bits e uma versão com produtos e acumuladores intermediários em 32 bits.

Apesar das diferenças na descrição C, o Vitis HLS normalizou as três versões e gerou a mesma organização interna de hardware: quatro multiplicações reais, duas operações para formar Tr e Ti e quatro somas ou subtrações finais para gerar as saídas.

A versão adotada como baseline oficial utiliza entradas e saídas de 16 bits, produtos e acumuladores intermediários de 32 bits e conversão para 16 bits somente nas saídas.

Essa implementação será utilizada como referência estrutural e aritmética para as próximas versões R1 a R7. As larguras dos intermediários poderão ser ajustadas quando as equações de cada estrutura exigirem pré-somas ou produtos com maior faixa numérica.

## R1 — Estrutura otimizada com três multiplicadores

A estrutura R1 foi implementada a partir da formulação otimizada de Renato, reduzindo a multiplicação complexa de quatro para três produtos reais.

As combinações intermediárias são:

Kplus = Wr + Wi
Kminus = Wr - Wi
SB = Br + Bi

Os três produtos reais são:

M0 = Br·Kplus
M1 = Wi·SB
M2 = Bi·Kminus

A multiplicação complexa é reconstruída por:

Tr = M0 - M1
Ti = M1 + M2

As saídas permanecem:

Cr = Ar + Tr
Dr = Ar - Tr
Ci = Ai + Ti
Di = Ai - Ti

Como as entradas possuem 16 bits, as pré-somas Kplus, Kminus e SB foram representadas com 17 bits. Os produtos entre operandos de 16 e 17 bits foram representados com 33 bits, enquanto Tr, Ti e os resultados temporários das saídas utilizaram 34 bits.

A implementação utilizou tipos ap_int do Vitis HLS para controlar explicitamente as larguras internas:

internal_data_t = ap_int<16>
preadd_t = ap_int<17>
product_t = ap_int<33>
accumulator_t = ap_int<34>

As saídas continuam sendo int16_t. A redução de 34 para 16 bits foi realizada somente ao final da borboleta, mantendo os 16 bits menos significativos e sem aplicação de saturação.

Foram avaliadas duas formas de realizar essa conversão final: uma conversão direta do acumulador de 34 bits para int16_t e uma redução intermediária explícita para ap_int<16>. O Vitis HLS eliminou as variáveis utilizadas apenas para conversão de largura e gerou o mesmo hardware para as duas descrições.

A versão com redução intermediária explícita foi mantida por deixar claro no código o ponto em que ocorre a conversão para 16 bits, mesmo sem produzir alteração no hardware sintetizado.

A organização aritmética apresentada ao Vitis HLS contém três pré-somas ou subtrações, três multiplicações reais, duas operações para reconstruir Tr e Ti e quatro somas ou subtrações finais para produzir as saídas.

Nesta implementação, Kplus e Kminus são calculados dentro da borboleta. Uma implementação futura poderá recebê-los pré-calculados juntamente com os twiddle factors, eliminando essas duas operações internas e produzindo uma variante arquitetural da R1.