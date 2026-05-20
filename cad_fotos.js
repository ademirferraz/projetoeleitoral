const fs = require('fs');
const path = require('path');

const pastaAssets = './assets';

// Dados exatos para a sua Quest de 2026
const questCandidatos = [
    { busca: 'flavio_bolsonaro', novo: 'flavio_bolsonaro_22_pl_presidente' },   
    { busca: 'lula', novo: 'lula_13_pt_presidente' },
    { busca: 'humberto_costa', novo: 'humberto_costa_131_pt_senador' },
    { busca: 'marilia_arraes', novo: 'marilia_arraes_12_pdt_governadora' },
    { busca: 'simone_tebet', novo: 'simone_tebet_40_psb_senador' },
    { busca: 'guilherme_derit', novo: 'guilherme_derrite_11_pp_senador' },
//  { busca: 'dannilo_godoy', novo: 'danilo_godoy_11_pp_deputado' }
//  { busca: 'daniel_godoy', novo: 'daniel_godoy_11_pp_prefeito' }

];

function executarOrganizacao() {
    console.log("--- Iniciando Organização da Quest EleicaoFluxo ---");

    if (!fs.existsSync(pastaAssets)) {
        console.error("Erro: A pasta ./assets não foi encontrada!");
        return;
    }

    const arquivosNaPasta = fs.readdirSync(pastaAssets);

    questCandidatos.forEach(item => {
        // Encontra o arquivo que contém o nome (ex: busca 'lula' no arquivo 'lula_13_pt.jpg')
        const arquivoAlvo = arquivosNaPasta.find(f => 
            f.toLowerCase().includes(item.busca.toLowerCase())
        );

        if (arquivoAlvo) {
            const extensao = path.extname(arquivoAlvo).toLowerCase();
            const novoNomeCompleto = `${item.novo}${extensao}`;
            
            const caminhoAntigo = path.join(pastaAssets, arquivoAlvo);
            const caminhoNovo = path.join(pastaAssets, novoNomeCompleto);

            try {
                fs.renameSync(caminhoAntigo, caminhoNovo);
                console.log(`✅ Sucesso: ${arquivoAlvo} -> ${novoNomeCompleto}`);
            } catch (err) {
                console.error(`❌ Erro ao renomear ${arquivoAlvo}:`, err.message);
            }
        } else {
            console.log(`⚠️ Aviso: Não encontrei foto para "${item.busca}" na pasta assets.`);
        }
    });

    console.log("--- Processo Finalizado ---");
}

executarOrganizacao();