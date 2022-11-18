// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./AcademicTypes.sol";
import {AcademicUtils} from "./AcademicUtils.sol";
import "./IAlunoContract.sol";

/**
 * @title Academic
 * @dev Academic system contract
 */
contract Academic {

   Periodo public etapa;

   mapping(uint => mapping(uint => uint8)) alunoIdToDisciplinaIdToNota;
   mapping(uint => Disciplina) disciplinaById;
   mapping(uint => uint[]) alunosByDisciplina;

   address owner;
   address _alunoContractAddr;

   constructor(){
       etapa = Periodo.INSCRICAO_ALUNOS;
       owner = msg.sender;
   }

   modifier onlyOwner(){
       require(msg.sender == owner, "Nao autorizado");
       _;
   }

   modifier onlyProfessor(uint disciplinaId){
       Disciplina memory d = disciplinaById[disciplinaId];
       require(d.professor != address(0), "Disciplina sem professor");
       require(msg.sender == d.professor, "Nao autorizado");
       _;
   }

   function setAlunoContractAddress(address alunoContractAddr) public onlyOwner {
       _alunoContractAddr = alunoContractAddr;
   }

   function abrirLancamentoNota() onlyOwner public {
       etapa = Periodo.LANCAMENTO_NOTAS;
   }

   function inserirDisciplina(uint id, string memory nome, address professor) onlyOwner public {
        disciplinaById[id] = Disciplina(id, nome, professor);
   }


   function inserirNota(uint alunoId, uint disciplinaId, uint8 nota) onlyProfessor(disciplinaId) public {
       require(bytes(IAlunoContract(_alunoContractAddr).getAlunoById(alunoId).nome).length != 0, "Aluno nao existente");
       require(etapa == Periodo.LANCAMENTO_NOTAS, "Fora do periodo de lancamento de notas");
       
       //if(bytes(alunoById[alunoId].nome).length == 0){
       //   revert("Aluno nao existente");
       //}
       
       //assert(bytes(alunoById[alunoId].nome).length != 0);

       alunoIdToDisciplinaIdToNota[alunoId][disciplinaId] = nota;
       alunosByDisciplina[disciplinaId].push(alunoId);

       AcademicUtils.soma(1, 2);
   }

   function listarNotasDisciplina(uint disciplinaId) view public returns(Aluno[] memory, uint8[] memory){
       uint numAlunos = alunosByDisciplina[disciplinaId].length;

       Aluno[] memory alunos = new Aluno[](numAlunos);
       uint8[] memory notas = new uint8[](numAlunos);

       for(uint i = 0; i < numAlunos; i++){
           uint alunoId = alunosByDisciplina[disciplinaId][i];
           
           alunos[i] = IAlunoContract(_alunoContractAddr).getAlunoById(alunoId);
           notas[i] = alunoIdToDisciplinaIdToNota[alunoId][disciplinaId];
       }
       return (alunos, notas);
   }



}
