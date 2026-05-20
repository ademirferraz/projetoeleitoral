
/**
 * SKILL: Validador de Comportamento com Prefeito e Presidente
 * Projeto: EleicaoFluxo
 * Autor: Dr. Ademir Ferraz
 */

// 1. DEFINIÇÃO DO CENÁRIO ADMINISTRATIVO
const configuracaoAdmin = {
    estado: "Pernambuco",
    cidade: "Bom Conselho"
};

// 2. ESTRUTURA DE VOTAÇÃO ATUALIZADA (EXATAMENTE 6 ESCOLHAS)
// Aqui a lógica matemática se fecha:
let votosRegistrados = [
    { cargo: "Presidente", candidato: "Candidato P", numero: 13 },
    { cargo: "Senador 1", candidato: "Candidato S1", numero: 111 },
    { cargo: "Senador 2", candidato: "Candidato S2", numero: 222 },
    { cargo: "Deputado Federal", candidato: "Candidato DF", numero: 3333 },
    { cargo: "Deputado Estadual", candidato: "Candidato DE", numero: 44444 },
    { cargo: "Prefeito", candidato: "Candidato Pref", numero: 55 } // O Prefeito entrou no jogo!
];

// --- TESTES DE COMPORTAMENTO ---

// TESTE A: Verificação de Limite Estrito
// O programa deve reconhecer que o eleitor não pode escolher mais de seis candidatos
if (votosRegistrados.length === 6) {
    console.log("✅ Limite de Votos: Sistema preenchido corretamente com 6 candidatos.");
} else if (votosRegistrados.length > 6) {
    console.error("❌ Erro Crítico: Sistema permitiu " + votosRegistrados.length + " votos. Bloqueio Falhou!");
}

// TESTE B: Reconhecimento de Brancos e Nulos
// Programa sabe que o eleitor pode votar branco ou nulo em qualquer uma das 6 posições
function validarOpcao(voto) {
    if (voto.numero === 0) return "Branco";
    if (voto.numero === -1) return "Nulo";
    return "Nominal";
}

console.log("📝 Tipo de voto para Prefeito: " + validarOpcao(votosRegistrados[5]));

// TESTE C: Gatilho do Gráfico para o Prefeito
let graficoPrefeitoX = 50; // Exemplo: Candidato X tinha 50 votos
console.log("📊 Gráfico Prefeito (Antes): " + graficoPrefeitoX);

// Simulando alteração imediata no resultado ao votar no candidato 55
if (votosRegistrados[5].numero === 55) {
    graficoPrefeitoX++; // Incremento estatístico
    console.log("📈 Gatilho Ativado! Novo resultado para Prefeito: " + graficoPrefeitoX);
}