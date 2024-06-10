-- queries solicitadas

-- Qual o cliente que mais fez pedidos por ano
WITH pedidos_por_ano AS (
    SELECT
        DATE_FORMAT(m.data_hora_entrada, '%Y') AS ano,
        c.id_cliente,
        c.nome_cliente,
        COUNT(*) AS numero_pedidos,
        ROW_NUMBER() OVER (PARTITION BY DATE_FORMAT(m.data_hora_entrada, '%Y') ORDER BY COUNT(*) DESC) AS rn
    FROM
        tb_pedido p
    JOIN
        tb_mesa m ON p.codigo_mesa = m.codigo_mesa
    JOIN
        tb_cliente c ON m.id_cliente = c.id_cliente
    WHERE
        m.data_hora_entrada >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    GROUP BY
        DATE_FORMAT(m.data_hora_entrada, '%Y'), c.id_cliente
)
SELECT
    ano,
    id_cliente,
    nome_cliente,
    numero_pedidos
FROM
    pedidos_por_ano
WHERE
    rn = 1
ORDER BY
    ano DESC;

-- Qual o cliente que mais gastou em todos os anos
WITH gasto_por_ano AS (
    SELECT
        DATE_FORMAT(m.data_hora_entrada, '%Y') AS ano,
        c.id_cliente,
        c.nome_cliente,
        SUM(p.quantidade_pedido * pr.preco_unitario_prato) AS total_gasto,
        ROW_NUMBER() OVER (PARTITION BY DATE_FORMAT(m.data_hora_entrada, '%Y') ORDER BY SUM(p.quantidade_pedido * pr.preco_unitario_prato) DESC) AS rn
    FROM
        tb_pedido p
    JOIN
        tb_mesa m ON p.codigo_mesa = m.codigo_mesa
    JOIN
        tb_cliente c ON m.id_cliente = c.id_cliente
    JOIN
        tb_prato pr ON p.codigo_prato = pr.codigo_prato
    GROUP BY
        DATE_FORMAT(m.data_hora_entrada, '%Y'), c.id_cliente
)
SELECT
    ano,
    id_cliente,
    nome_cliente,
    total_gasto
FROM
    gasto_por_ano
WHERE
    rn = 1
ORDER BY
    ano DESC;

-- Qual(is) o(s) cliente(s) que trouxe(ram) mais pessoas por ano

select distinct year(data_hora_entrada)
from tb_mesa;

select year(ms.data_hora_entrada) as ano, cl.nome_cliente as cliente, sum(ms.num_pessoa_mesa) as qtd_pessoas 
from tb_mesa ms
left join tb_cliente cl
on ms.id_cliente = cl.id_cliente
where year(ms.data_hora_entrada) = 2022
group by 1,2
order by 3 desc
limit 3;


select * 
from (
(select year(ms.data_hora_entrada) as ano, cl.nome_cliente as cliente, sum(ms.num_pessoa_mesa) as qtd_pessoas 
from tb_mesa ms
left join tb_cliente cl
on ms.id_cliente = cl.id_cliente
where year(ms.data_hora_entrada) = 2022
group by 1,2
order by 3 desc
limit 1)
union
(select year(ms.data_hora_entrada) as ano, cl.nome_cliente as cliente, sum(ms.num_pessoa_mesa) as qtd_pessoas 
from tb_mesa ms
left join tb_cliente cl
on ms.id_cliente = cl.id_cliente
where year(ms.data_hora_entrada) = 2023
group by 1,2
order by 3 desc
limit 1)
union(
select year(ms.data_hora_entrada) as ano, cl.nome_cliente as cliente, sum(ms.num_pessoa_mesa) as qtd_pessoas 
from tb_mesa ms
left join tb_cliente cl
on ms.id_cliente = cl.id_cliente
where year(ms.data_hora_entrada) = 2024
group by 1,2
order by 3 desc
limit 1
)) as
top1_mais_convidados_por_ano;

-- Qual a empresa que tem mais funcionarios como clientes do restaurante;
SELECT 
    e.nome_empresa,
    COUNT(*) AS numero_funcionarios_clientes
FROM 
    tb_cliente c
JOIN 
    tb_beneficio b ON c.email_cliente = b.email_funcionario
JOIN 
    tb_empresa e ON b.cod_empresa = e.cod_empresa
GROUP BY 
    e.nome_empresa
ORDER BY 
    numero_funcionarios_clientes DESC
LIMIT 1;



-- Qual empresa que tem mais funcionarios que consomem sobremesas no restaurante por ano;

WITH ConsumoSobremesaPorAno AS (
    SELECT 
        YEAR(m.data_hora_entrada) AS ano,
        e.nome_empresa,
        COUNT(DISTINCT b.cod_funcionario) AS numero_funcionarios_sobremesa
    FROM 
        tb_cliente c
    JOIN 
        tb_beneficio b ON c.email_cliente = b.email_funcionario
    JOIN 
        tb_empresa e ON b.cod_empresa = e.cod_empresa
    JOIN 
        tb_mesa m ON c.id_cliente = m.id_cliente
    JOIN 
        tb_pedido p ON m.codigo_mesa = p.codigo_mesa
    JOIN 
        tb_tipo_prato tp ON p.codigo_prato = tp.codigo_tipo_prato
    WHERE 
        tp.nome_tipo_prato = 'Sobremesa' AND
        YEAR(m.data_hora_entrada) IN (2022, 2023, 2024)
    GROUP BY 
        ano, e.nome_empresa
),
MaxConsumoPorAno AS (
    SELECT 
        ano,
        MAX(numero_funcionarios_sobremesa) AS max_funcionarios_sobremesa
    FROM 
        ConsumoSobremesaPorAno
    GROUP BY 
        ano
)
SELECT 
    c.ano,
    c.nome_empresa,
    c.numero_funcionarios_sobremesa
FROM 
    ConsumoSobremesaPorAno c
JOIN 
    MaxConsumoPorAno m ON c.ano = m.ano AND c.numero_funcionarios_sobremesa = m.max_funcionarios_sobremesa
ORDER BY 
    c.ano, c.nome_empresa;

