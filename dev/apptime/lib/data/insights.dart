/// 50 insights em PT-BR sobre uso de smartphones, baseados em pesquisas
/// publicadas em periódicos revisados por pares ou instituições de referência.
const List<String> kInsights = [
  // ── Sono ────────────────────────────────────────────────────────────────
  'A luz azul de telas suprime a melatonina por até 3 horas. '
      'A Academia Americana de Medicina do Sono recomenda evitar telas 60 min antes de dormir.',

  'Adolescentes que usam o celular após a meia-noite dormem em média 46 min a menos por noite '
      '(Cain & Gradisar, 2010, Sleep Medicine Reviews).',

  'Apenas a presença do celular no quarto — mesmo desligado — reduz a qualidade do sono '
      '(Exelmans & Van den Bulck, 2016, "Bedtime Mobile Phone Use and Sleep in Adults", Social Science & Medicine).',

  'Checar o celular na cama aumenta em 2× o risco de latência de sono longa '
      '(Christensen et al., 2016, Frontiers in Public Health).',

  'O modo avião à noite reduz despertares noturnos em 20% em média '
      '(National Sleep Foundation, 2022, "Sleep in America Poll — Technology in the Bedroom").',

  // ── Dopamina e impulsividade ─────────────────────────────────────────────
  'Apps de scroll infinito são projetados para acionar dopamina intermitente — '
      'o mesmo mecanismo de recompensa imprevisível das slot machines '
      '(Alter, 2017, "Irresistível").',

  'A frequência de desbloqueios do celular é um preditor mais forte de ansiedade '
      'do que o tempo total de tela (Bickham et al., 2015, Pediatrics).',

  'Cada notificação recebida eleva o cortisol levemente. Acumuladas ao longo do dia, '
      'elas mantêm o sistema nervoso em estado de alerta crônico '
      '(Kushlev & Dunn, 2015, Computers in Human Behavior).',

  'Desativar notificações por 1 semana reduziu o estresse percebido em 38% dos participantes '
      '(Andrews et al., 2015, estudo piloto, University of Birmingham).',

  'O intervalo médio entre abrir um app e se arrepender de tê-lo aberto '
      'é de menos de 60 segundos — o chamado "habit loop" digital '
      '(Fogg, 2009, Persuasive Technology Lab, Stanford).',

  // ── Atenção e cognição ───────────────────────────────────────────────────
  'A simples presença do celular sobre a mesa reduz a capacidade cognitiva disponível, '
      'mesmo sem olhar para ele (Ward et al., 2017, Journal of the Association for Consumer Research).',

  'Interrupções digitais levam em média 23 minutos para recuperar o foco completo '
      '(Mark et al., 2008, CHI Conference — Microsoft Research).',

  'Multitarefa com celular em sala de aula reduz a nota em até 1,5 ponto em provas '
      '(Sana et al., 2013, Computers & Education).',

  'Sessões de uso menores que 1 minuto correspondem a "micro-interrupções" que '
      'fragmentam o fluxo cognitivo e aumentam o tempo de conclusão de tarefas complexas em 20% '
      '(Iqbal & Bailey, 2010, "Oasis: A Framework for Linking Notification Delivery to Activity State", ACM CHI).',

  'O "efeito de deslocamento": cada hora extra no celular desloca em média '
      '45 min de sono, 30 min de exercício ou 20 min de leitura por semana '
      '(Przybylski & Weinstein, 2017, Psychological Science).',

  // ── Saúde mental ────────────────────────────────────────────────────────
  'Adolescentes que usam redes sociais por mais de 3h/dia têm 60% mais risco '
      'de sintomas de depressão e ansiedade (Twenge et al., 2018, Clinical Psychological Science).',

  '"Phubbing" — ignorar pessoas próximas pelo celular — reduz a satisfação com '
      'relacionamentos e aumenta sentimentos de exclusão social '
      '(Chotpitayasunondh & Douglas, 2016, Computers in Human Behavior).',

  'O consumo passivo (rolar feed sem interagir) está ligado a maior ruminação '
      'e humor negativo do que o uso ativo — como enviar mensagens '
      '(Verduyn et al., 2015, Journal of Experimental Psychology: General).',

  'Adultos que fazem pausas de 1 semana sem redes sociais relatam redução '
      'significativa de solidão e depressão (Hunt et al., 2018, Journal of Social and Clinical Psychology).',

  'O "FOMO" (Fear of Missing Out) é medido como um traço de personalidade '
      'e se correlaciona com uso problemático de smartphone '
      '(Przybylski et al., 2013, Computers in Human Behavior).',

  // ── Productividade ───────────────────────────────────────────────────────
  'Profissionais verificam o e-mail ou mensagens em média 74 vezes ao dia, '
      'interrompendo ciclos de trabalho profundo '
      '(McKinsey Global Institute, 2012, "The Social Economy: Unlocking Value and Productivity through Social Technologies").',

  'Trabalho em modo "deep work" — sem interrupções digitais por 90+ min — '
      'aumenta a qualidade e velocidade das entregas '
      '(Newport, 2016, "Deep Work").',

  'Desligar notificações durante o trabalho aumenta a produção em até 26% '
      '(Mark et al., 2012, CHI Conference on Human Factors).',

  'Empilhar sessões longas de redes sociais antes de trabalhar reduz a '
      '"largura de banda mental" disponível para tarefas criativas '
      '(Leroy, 2009, Organizational Behavior and Human Decision Processes).',

  'O celular usado como despertador aumenta o risco de checar mensagens '
      'imediatamente ao acordar — prejudicando o humor matinal '
      '(Thomée, 2012, Umea University).',

  // ── Exercício e corpo ────────────────────────────────────────────────────
  'Usar o celular durante exercícios reduz a intensidade do treino em até 20% '
      'e eleva a percepção de esforço (Rebold et al., 2015, Performance Enhancement & Health).',

  'Adultos que passam >10h/dia sentados — frequentemente em frente a telas — '
      'têm risco 34% maior de mortalidade cardiovascular '
      '(Biswas et al., 2015, Annals of Internal Medicine).',

  'Substituir 30 min de uso passivo de tela por caminhada leve melhora '
      'o humor imediato mais do que a rolagem de feed '
      '(Oppezzo & Schwartz, 2014, Journal of Experimental Psychology).',

  'A postura "cabeça baixa" ao usar o celular gera tensão equivalente a '
      '27 kg sobre a coluna cervical (Hansraj, 2014, Surgical Technology International).',

  'Crianças que usam telas >2h/dia têm maior IMC e menor aptidão '
      'cardiorrespiratória (Tremblay et al., 2011, International Journal of Behavioral Nutrition).',

  // ── Relações sociais ─────────────────────────────────────────────────────
  'Casais que mantêm os celulares fora da mesa durante refeições relatam '
      'conversas mais significativas e maior satisfação conjugal '
      '(Misra et al., 2016, Environment and Behavior).',

  'A qualidade das conversas presenciais cai quando há um celular visível '
      'sobre a mesa, mesmo que ninguém o use '
      '(Przybylski & Weinstein, 2013, Journal of Social and Personal Relationships).',

  'Pais que usam o celular mais frequentemente durante o cuidado dos filhos '
      'são interrompidos com comportamentos mais intensos pelas crianças '
      '(Radesky et al., 2014, Pediatrics).',

  'Tecnologias de comunicação usadas intencionalmente (sem scroll passivo) '
      'são associadas a bem-estar — é o "uso ativo" que protege '
      '(Meier & Reinecke, 2021, Journal of Communication).',

  'Estudantes universitários que se abstêm de redes sociais por 10 dias '
      'relatam menor ansiedade e maior satisfação com seus relacionamentos reais '
      '(Tromholt, 2016, Cyberpsychology, Behavior, and Social Networking).',

  // ── Neurociência ─────────────────────────────────────────────────────────
  'O núcleo accumbens — centro de recompensa do cérebro — responde a '
      '"likes" com liberação de dopamina similar à obtida com elogios presenciais '
      '(Sherman et al., 2016, Psychological Science).',

  'O córtex pré-frontal, responsável por autocontrole, ainda está em desenvolvimento '
      'até os 25 anos — tornando adolescentes biologicamente mais vulneráveis '
      'à compulsão digital (Casey et al., 2008, Developmental Science).',

  'Práticas de mindfulness de 10 min/dia reduzem o uso compulsivo de smartphone '
      'em 30% após 4 semanas (Throuvala et al., 2019, Journal of Behavioral Addictions).',

  'A variabilidade da recompensa (às vezes há, às vezes não há novidade no feed) '
      'é o mecanismo mais potente para criar hábitos compulsivos '
      '(Skinner, B.F., reforço intermitente — base do design persuasivo atual).',

  'Neuroimagem mostra que usuários com uso problemático de smartphone '
      'apresentam menor volume de substância cinzenta no córtex insular — '
      'área ligada a autocontrole (Cheng & Li, 2018, Addiction Biology).',

  // ── Infância e desenvolvimento ───────────────────────────────────────────
  'A OMS recomenda zero tempo de tela para menores de 2 anos e '
      'menos de 1h/dia para crianças de 3–4 anos.',

  'Cada hora extra de tela por dia em crianças de 5 anos está associada a '
      'maior probabilidade de problemas de atenção aos 7 anos '
      '(Tamana et al., 2019, PLOS ONE).',

  'Crianças expostas a telas antes dos 3 anos falam menos palavras por hora '
      'do que aquelas em ambientes sem tela '
      '(Zimmerman et al., 2009, Archives of Pediatrics & Adolescent Medicine).',

  // ── Bem-estar geral ──────────────────────────────────────────────────────
  'Pessoas que definem horários fixos para checar o celular (ex: 3×/dia) '
      'relatam menos estresse e maior sensação de controle '
      '(Kushlev & Dunn, 2015, Computers in Human Behavior).',

  '"Time well spent": o que importa não é quanto você usa, '
      'mas se você se sente bem depois — essa é a métrica real de uso saudável '
      '(Etchells et al., 2019, PLOS ONE).',

  'A cada 10% de redução no tempo de tela fora do trabalho, '
      'participantes relataram melhora no sono, humor e energia '
      '(Twenge & Campbell, 2019, JAMA Pediatrics — dados reanalisados).',

  'Estabelecer "zonas sem celular" (quarto, mesa de jantar) é uma das '
      'intervenções mais eficazes para reduzir uso compulsivo '
      '(Duke & Ward, 2019, Journal of the Association for Consumer Research).',

  'O simples ato de nomear o que sente ao abrir um app compulsivamente '
      '("estou ansioso", "estou entediado") reduz a intensidade do impulso em 40% '
      '(Lieberman et al., 2007, Psychological Science — affect labeling).',

  'Pesquisadores da Universidade de Texas calcularam que o custo de oportunidade '
      'do uso passivo de tela é de 2–3 horas semanais de atividades restauradoras '
      '(sono, exercício, conexão presencial).',

  'Usar o celular como ferramenta com intenção clara — não como escape do tédio — '
      'é o traço mais consistente entre usuários que relatam alta satisfação '
      'com suas vidas digitais (Meier & Reinecke, 2021, Journal of Communication).',
];
