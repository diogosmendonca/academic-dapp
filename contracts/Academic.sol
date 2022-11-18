// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Academic
 * @dev Academic system contract
 */
contract Academic {

   struct Aluno{
       uint id;
       string nome; 
   }

   struct Disciplina{
       uint id;
       string nome;
   }

   enum Periodo {
       INSCRICAO_ALUNOS,
       LANCAMENTO_NOTAS
   }

   Periodo etapa;

   mapping(uint => mapping(uint => uint8)) alunoIdToDisciplinaIdToNota;
   mapping(uint => Aluno) alunoById;
   mapping(uint => Disciplina) disciplinaById;
   mapping(uint => uint[]) alunosByDisciplina;

   address owner;

   constructor(){
       etapa = Periodo.INSCRICAO_ALUNOS;
       owner = msg.sender;
   }

   function abrirLancamentoNota() public {
       require(msg.sender == owner, "Nao autorizado");
       etapa = Periodo.LANCAMENTO_NOTAS;
   }

   function inserirAluno(uint id, string memory nome) public {
       require(etapa == Periodo.INSCRICAO_ALUNOS, "Fora do periodo de inscricao de aluno");
       alunoById[id] = Aluno(id, nome);
   }

   function inserirNota(uint alunoId, uint disciplinaId, uint8 nota) public {
       require(bytes(alunoById[alunoId].nome).length != 0, "Aluno nao existente");
       require(etapa == Periodo.LANCAMENTO_NOTAS, "Fora do periodo de lancamento de notas");
       
       //if(bytes(alunoById[alunoId].nome).length == 0){
       //   revert("Aluno nao existente");
       //}
       
       //assert(bytes(alunoById[alunoId].nome).length != 0);

       alunoIdToDisciplinaIdToNota[alunoId][disciplinaId] = nota;
       alunosByDisciplina[disciplinaId].push(alunoId);
   }

   function listarNotasDisciplina(uint disciplinaId) view public returns(Aluno[] memory, uint8[] memory){
       uint numAlunos = alunosByDisciplina[disciplinaId].length;

       Aluno[] memory alunos = new Aluno[](numAlunos);
       uint8[] memory notas = new uint8[](numAlunos);

       for(uint i = 0; i < numAlunos; i++){
           uint alunoId = alunosByDisciplina[disciplinaId][i];

           alunos[i] = alunoById[alunoId];
           notas[i] = alunoIdToDisciplinaIdToNota[alunoId][disciplinaId];
       }
       return (alunos, notas);
   }



}
