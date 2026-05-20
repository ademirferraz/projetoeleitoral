/**
 * TESTE DE VOTO EM BRANCO - EleicaoFluxo
 */

// 1. SITUAÇÃO: Eleitor decide votar BRANCO para Presidente
let votoPresidente = { cargo: "Presidente", candidato: "Branco", numero: 0 };

// 2. ESTADO DOS GRÁFICOS (Votos Nominais)
let graficoCandidatoA = 100;
let graficoBrancos = 20;

console.log("📊 Antes do Voto - Candidato A: " + graficoCandidatoA + " | Brancos: " + graficoBrancos);

// 3. LÓGICA DE GATILHO
if (votoPresidente.numero === 0) {
    graficoBrancos++; // Só a barra de brancos deve subir
    console.log("⚪ Voto em BRANCO registrado.");
} else if (votoPresidente.numero === 13) {
    graficoCandidatoA++;
}

// 4. RESULTADO FINAL
console.log("📊 Após o Voto - Candidato A: " + graficoCandidatoA + " | Brancos: " + graficoBrancos);

// VALIDAÇÃO ESTATÍSTICA
if (graficoCandidatoA === 100 && graficoBrancos === 21) {
    console.log("✅ SUCESSO: O gráfico nominal não foi alterado indevidamente.");
} else {
    console.error("❌ ERRO: Falha na segregação dos votos.");
}