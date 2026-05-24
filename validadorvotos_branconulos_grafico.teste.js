/**
 * VALIDADOR: Brancos e Nulos (Skill de Integridade)
 * Projeto: EleicaoFluxo - Escopo Nacional
 */

// Simulação de Banco de Dados Inicial
let totalNominal = 100;
let totalBrancos = 10;
let totalNulos = 5;

function processarVoto(numero) {
    if (numero === 0) {
        totalBrancos++;
        return "BRANCO";
    } else if (numero === -1) {
        totalNulos++;
        return "NULO";
    } else {
        totalNominal++;
        return "NOMINAL";
    }
}

console.log("📊 Estado Inicial -> Nominais: " + totalNominal + " | Brancos: " + totalBrancos + " | Nulos: " + totalNulos);

// Simulando 1 Voto em Branco e 1 Voto Nulo
processarVoto(0);  // Branco
processarVoto(-1); // Nulo

console.log("📊 Estado Final   -> Nominais: " + totalNominal + " | Brancos: " + totalBrancos + " | Nulos: " + totalNulos);

// VALIDAÇÃO MATEMÁTICA
if (totalNominal === 100 && totalBrancos === 11 && totalNulos === 6) {
    console.log("✅ SUCESSO: A segregação de votos brancos e nulos está correta!");
} else {
    console.error("❌ ERRO: A matemática dos votos falhou.");
}