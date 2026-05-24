const cidadeAdmin = "Recife";
const estadoAdmin = "PE";

const eleitoresParaTeste = [
  { id: 1, nome: "Candidato CPF Errado", cpf: "123", idade: 20, cidade: "Recife", estado: "PE", pres: ["A"], pref: "Recife", leg: "PE" },
  { id: 2, nome: "Jovem Menor de 16", cpf: "12345678901", idade: 15, cidade: "Recife", estado: "PE", pres: ["A"], pref: "Recife", leg: "PE" },
  { id: 3, nome: "Recifense em Olinda", cpf: "12345678901", idade: 30, cidade: "Recife", estado: "PE", pres: ["A"], pref: "Olinda", leg: "PE" },
  { id: 4, nome: "Pernambucano na PB", cpf: "12345678901", idade: 45, cidade: "Recife", estado: "PE", pres: ["A"], pref: "Recife", leg: "PB" },
  { id: 5, nome: "Voto Duplo Presidencial", cpf: "12345678901", idade: 50, cidade: "Recife", estado: "PE", pres: ["A", "B"], pref: "Recife", leg: "PE" },
  { id: 6, nome: "Eleitor Regular 1", cpf: "12345678901", idade: 18, cidade: "Recife", estado: "PE", pres: ["A"], pref: "Recife", leg: "PE" },
  { id: 7, nome: "Eleitor Regular 2", cpf: "98765432100", idade: 74, cidade: "Recife", estado: "PE", pres: ["B"], pref: "Recife", leg: "PE" },
  { id: 8, nome: "CPF Curto", cpf: "000", idade: 25, cidade: "Recife", estado: "PE", pres: ["A"], pref: "Recife", leg: "PE" },
  { id: 9, nome: "Fora do Estado (Senador)", cpf: "12345678901", idade: 22, cidade: "Recife", estado: "PE", pres: ["A"], pref: "Recife", leg: "RJ" },
  { id: 10, nome: "Idoso Ativo", cpf: "11122233344", idade: 80, cidade: "Recife", estado: "PE", pres: ["C"], pref: "Recife", leg: "PE" }
];

eleitoresParaTeste.forEach(e => {
  console.log(`\n>>> Rodando Teste #${e.id}: ${e.nome}`);
  
  if (e.cpf.length !== 11) { console.error("SAÍDA: CPF inválido"); return; }
  if (e.idade < 16) { console.error("SAÍDA: Você não pode votar"); return; }
  if (e.pref !== e.cidade) { console.error("SAÍDA: Você deve votar no prefeito de sua cidade"); return; }
  if (e.leg !== e.estado) { console.error("SAÍDA: Vote em candidatos do seu Estado"); return; }
  if (e.pres.length > 1) { console.error("SAÍDA: Você só pode votar em um candidato a presidência"); return; }
  
  console.log("✅ RESULTADO: Voto Confirmado com Sucesso!");
});