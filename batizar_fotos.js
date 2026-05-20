const fs = require('fs');
const path = require('path');

const pastaAssets = './assets';

// CONFIGURAÇÃO DOS TESTES (Descomente conforme for avançando)
const questCandidatos = [
    { busca: 'lula', novo: 'lula_13_pt_presidente' },             // TESTE 1
    { busca: 'flavio', novo: 'flavio_bolsonaro_22_pl_senador' },   // TESTE 2
    { busca: 'marilia', novo: 'marilia_arraes_12_pdt_senador' },   // TESTE 3
    // { busca: 'humberto', novo: 'humberto_costa_131_pt_senador' },
    // { busca: 'simone', novo: 'simone_tebet_40_psb_senador' },
    // { busca: 'derit', novo: 'guilherme_derrite_11_pp_senador' },
    // { busca: 'godoy', novo: 'dannilo_godoy_11_pp_estadual' }
];

const arquivosNaPasta = fs.readdirSync(pastaAssets);

console.log("--- ORGANIZANDO FOTOS PARA O PAINEL ---");

questCandidatos.forEach(item => {
    const arquivoAlvo = arquivosNaPasta.find(f => 
        f.toLowerCase().includes(item.busca.toLowerCase())
    );

    if (arquivoAlvo) {
        const extensao = path.extname(arquivoAlvo).toLowerCase();
        const novoNome = `${item.novo}${extensao}`;
        
        fs.renameSync(path.join(pastaAssets, arquivoAlvo), path.join(pastaAssets, novoNome));
        console.log(`✅ ${arquivoAlvo} -> ${novoNome}`);
    }
});