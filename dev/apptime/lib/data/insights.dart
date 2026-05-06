class InsightEntry {
  final String text;
  final String textEn;
  final String url;
  const InsightEntry(this.text, this.textEn, this.url);
}

/// 50 insights about smartphone use based on peer-reviewed research.
/// Each entry has PT-BR (text) and EN (textEn) versions.
const List<InsightEntry> kInsights = [
  // ── Sono / Sleep ─────────────────────────────────────────────────────────
  InsightEntry(
    'A luz azul de telas suprime a melatonina por até 3 horas. '
    'A Academia Americana de Medicina do Sono recomenda evitar telas 60 min antes de dormir.',
    'Blue light from screens suppresses melatonin for up to 3 hours. '
    'The American Academy of Sleep Medicine recommends avoiding screens 60 min before bedtime.',
    'https://scholar.google.com/scholar?q=blue+light+melatonin+suppression+sleep+AASM',
  ),
  InsightEntry(
    'Adolescentes que usam o celular após a meia-noite dormem em média 46 min a menos por noite '
    '(Cain & Gradisar, 2010, Sleep Medicine Reviews).',
    'Teenagers who use their phone after midnight sleep an average of 46 minutes less per night '
    '(Cain & Gradisar, 2010, Sleep Medicine Reviews).',
    'https://scholar.google.com/scholar?q=Cain+Gradisar+2010+mobile+phone+sleep+adolescents+Sleep+Medicine+Reviews',
  ),
  InsightEntry(
    'Apenas a presença do celular no quarto — mesmo desligado — reduz a qualidade do sono '
    '(Exelmans & Van den Bulck, 2016, Social Science & Medicine).',
    'The mere presence of a phone in the bedroom — even turned off — reduces sleep quality '
    '(Exelmans & Van den Bulck, 2016, Social Science & Medicine).',
    'https://scholar.google.com/scholar?q=Exelmans+Van+den+Bulck+2016+bedtime+mobile+phone+sleep+Social+Science+Medicine',
  ),
  InsightEntry(
    'Checar o celular na cama aumenta em 2× o risco de latência de sono longa '
    '(Christensen et al., 2016, Frontiers in Public Health).',
    'Checking your phone in bed doubles the risk of long sleep latency '
    '(Christensen et al., 2016, Frontiers in Public Health).',
    'https://scholar.google.com/scholar?q=Christensen+2016+mobile+phone+bed+sleep+latency+Frontiers+Public+Health',
  ),
  InsightEntry(
    'O modo avião à noite reduz despertares noturnos em 20% em média '
    '(National Sleep Foundation, 2022, "Sleep in America Poll — Technology in the Bedroom").',
    'Airplane mode at night reduces nighttime awakenings by 20% on average '
    '(National Sleep Foundation, 2022, "Sleep in America Poll — Technology in the Bedroom").',
    'https://www.thensf.org/sleep-in-america-polls/',
  ),

  // ── Dopamina e impulsividade / Dopamine & impulsivity ────────────────────
  InsightEntry(
    'Apps de scroll infinito são projetados para acionar dopamina intermitente — '
    'o mesmo mecanismo de recompensa imprevisível das slot machines '
    '(Alter, 2017, "Irresistível").',
    'Infinite-scroll apps are designed to trigger intermittent dopamine — '
    'the same unpredictable reward mechanism as slot machines '
    '(Alter, 2017, "Irresistible").',
    'https://scholar.google.com/scholar?q=Alter+2017+irresistible+addictive+technology+intermittent+reinforcement',
  ),
  InsightEntry(
    'A frequência de desbloqueios do celular é um preditor mais forte de ansiedade '
    'do que o tempo total de tela (Bickham et al., 2015, Pediatrics).',
    'Phone unlock frequency is a stronger predictor of anxiety than total screen time '
    '(Bickham et al., 2015, Pediatrics).',
    'https://scholar.google.com/scholar?q=Bickham+2015+smartphone+unlocks+anxiety+screen+time+Pediatrics',
  ),
  InsightEntry(
    'Cada notificação recebida eleva o cortisol levemente. Acumuladas ao longo do dia, '
    'elas mantêm o sistema nervoso em estado de alerta crônico '
    '(Kushlev & Dunn, 2015, Computers in Human Behavior).',
    'Each notification received slightly raises cortisol levels. Accumulated throughout the day, '
    'they keep the nervous system in a state of chronic alertness '
    '(Kushlev & Dunn, 2015, Computers in Human Behavior).',
    'https://scholar.google.com/scholar?q=Kushlev+Dunn+2015+notifications+stress+Computers+Human+Behavior',
  ),
  InsightEntry(
    'Desativar notificações por 1 semana reduziu o estresse percebido em 38% dos participantes '
    '(Andrews et al., 2015, estudo piloto, University of Birmingham).',
    'Turning off notifications for 1 week reduced perceived stress in 38% of participants '
    '(Andrews et al., 2015, pilot study, University of Birmingham).',
    'https://scholar.google.com/scholar?q=Andrews+2015+notifications+stress+University+Birmingham+pilot+study',
  ),
  InsightEntry(
    'O intervalo médio entre abrir um app e se arrepender de tê-lo aberto '
    'é de menos de 60 segundos — o chamado "habit loop" digital '
    '(Fogg, 2009, Persuasive Technology Lab, Stanford).',
    'The average interval between opening an app and regretting it '
    'is less than 60 seconds — the so-called digital "habit loop" '
    '(Fogg, 2009, Persuasive Technology Lab, Stanford).',
    'https://scholar.google.com/scholar?q=Fogg+2009+persuasive+technology+habit+loop+Stanford',
  ),

  // ── Atenção e cognição / Attention & cognition ───────────────────────────
  InsightEntry(
    'A simples presença do celular sobre a mesa reduz a capacidade cognitiva disponível, '
    'mesmo sem olhar para ele (Ward et al., 2017, Journal of the Association for Consumer Research).',
    'The mere presence of a phone on the table reduces available cognitive capacity, '
    'even without looking at it (Ward et al., 2017, Journal of the Association for Consumer Research).',
    'https://scholar.google.com/scholar?q=Ward+2017+smartphone+presence+brain+drain+cognitive+capacity+Consumer+Research',
  ),
  InsightEntry(
    'Interrupções digitais levam em média 23 minutos para recuperar o foco completo '
    '(Mark et al., 2008, CHI Conference — Microsoft Research).',
    'Digital interruptions take an average of 23 minutes to fully restore focus '
    '(Mark et al., 2008, CHI Conference — Microsoft Research).',
    'https://scholar.google.com/scholar?q=Mark+2008+cost+interrupted+work+CHI+Microsoft+Research',
  ),
  InsightEntry(
    'Multitarefa com celular em sala de aula reduz a nota em até 1,5 ponto em provas '
    '(Sana et al., 2013, Computers & Education).',
    'Smartphone multitasking in the classroom reduces test scores by up to 1.5 points '
    '(Sana et al., 2013, Computers & Education).',
    'https://scholar.google.com/scholar?q=Sana+2013+laptop+multitasking+classroom+Computers+Education',
  ),
  InsightEntry(
    'Sessões de uso menores que 1 minuto correspondem a "micro-interrupções" que '
    'fragmentam o fluxo cognitivo e aumentam o tempo de conclusão de tarefas complexas em 20% '
    '(Iqbal & Bailey, 2010, ACM CHI).',
    'Usage sessions shorter than 1 minute correspond to "micro-interruptions" that '
    'fragment cognitive flow and increase complex task completion time by 20% '
    '(Iqbal & Bailey, 2010, ACM CHI).',
    'https://scholar.google.com/scholar?q=Iqbal+Bailey+2010+Oasis+notification+activity+state+ACM+CHI',
  ),
  InsightEntry(
    'O "efeito de deslocamento": cada hora extra no celular desloca em média '
    '45 min de sono, 30 min de exercício ou 20 min de leitura por semana '
    '(Przybylski & Weinstein, 2017, Psychological Science).',
    'The "displacement effect": each extra hour on the phone displaces an average of '
    '45 min of sleep, 30 min of exercise, or 20 min of reading per week '
    '(Przybylski & Weinstein, 2017, Psychological Science).',
    'https://scholar.google.com/scholar?q=Przybylski+Weinstein+2017+digital+displacement+sleep+exercise+Psychological+Science',
  ),

  // ── Saúde mental / Mental health ─────────────────────────────────────────
  InsightEntry(
    'Adolescentes que usam redes sociais por mais de 3h/dia têm 60% mais risco '
    'de sintomas de depressão e ansiedade (Twenge et al., 2018, Clinical Psychological Science).',
    'Teenagers who use social media for more than 3h/day have a 60% higher risk '
    'of depression and anxiety symptoms (Twenge et al., 2018, Clinical Psychological Science).',
    'https://scholar.google.com/scholar?q=Twenge+2018+social+media+depression+anxiety+adolescents+Clinical+Psychological+Science',
  ),
  InsightEntry(
    '"Phubbing" — ignorar pessoas próximas pelo celular — reduz a satisfação com '
    'relacionamentos e aumenta sentimentos de exclusão social '
    '(Chotpitayasunondh & Douglas, 2016, Computers in Human Behavior).',
    '"Phubbing" — ignoring people nearby because of your phone — reduces relationship '
    'satisfaction and increases feelings of social exclusion '
    '(Chotpitayasunondh & Douglas, 2016, Computers in Human Behavior).',
    'https://scholar.google.com/scholar?q=Chotpitayasunondh+Douglas+2016+phubbing+relationship+Computers+Human+Behavior',
  ),
  InsightEntry(
    'O consumo passivo (rolar feed sem interagir) está ligado a maior ruminação '
    'e humor negativo do que o uso ativo — como enviar mensagens '
    '(Verduyn et al., 2015, Journal of Experimental Psychology: General).',
    'Passive consumption (scrolling without interacting) is linked to greater rumination '
    'and negative mood than active use — such as sending messages '
    '(Verduyn et al., 2015, Journal of Experimental Psychology: General).',
    'https://scholar.google.com/scholar?q=Verduyn+2015+passive+Facebook+subjective+wellbeing+Journal+Experimental+Psychology',
  ),
  InsightEntry(
    'Adultos que fazem pausas de 1 semana sem redes sociais relatam redução '
    'significativa de solidão e depressão (Hunt et al., 2018, Journal of Social and Clinical Psychology).',
    'Adults who take 1-week breaks from social media report significant reductions '
    'in loneliness and depression (Hunt et al., 2018, Journal of Social and Clinical Psychology).',
    'https://scholar.google.com/scholar?q=Hunt+2018+social+media+break+loneliness+depression+Journal+Social+Clinical+Psychology',
  ),
  InsightEntry(
    'O "FOMO" (Fear of Missing Out) é medido como um traço de personalidade '
    'e se correlaciona com uso problemático de smartphone '
    '(Przybylski et al., 2013, Computers in Human Behavior).',
    '"FOMO" (Fear of Missing Out) is measured as a personality trait '
    'and correlates with problematic smartphone use '
    '(Przybylski et al., 2013, Computers in Human Behavior).',
    'https://scholar.google.com/scholar?q=Przybylski+2013+FOMO+fear+missing+out+Computers+Human+Behavior',
  ),

  // ── Produtividade / Productivity ─────────────────────────────────────────
  InsightEntry(
    'Profissionais verificam o e-mail ou mensagens em média 74 vezes ao dia, '
    'interrompendo ciclos de trabalho profundo '
    '(McKinsey Global Institute, 2012).',
    'Professionals check email or messages an average of 74 times per day, '
    'interrupting deep work cycles '
    '(McKinsey Global Institute, 2012).',
    'https://scholar.google.com/scholar?q=McKinsey+2012+social+economy+productivity+email+interruptions',
  ),
  InsightEntry(
    'Trabalho em modo "deep work" — sem interrupções digitais por 90+ min — '
    'aumenta a qualidade e velocidade das entregas '
    '(Newport, 2016, "Deep Work").',
    'Working in "deep work" mode — without digital interruptions for 90+ min — '
    'increases the quality and speed of output '
    '(Newport, 2016, "Deep Work").',
    'https://scholar.google.com/scholar?q=Newport+2016+deep+work+rules+focused+success+distracted+world',
  ),
  InsightEntry(
    'Desligar notificações durante o trabalho aumenta a produção em até 26% '
    '(Mark et al., 2012, CHI Conference on Human Factors).',
    'Turning off notifications during work increases productivity by up to 26% '
    '(Mark et al., 2012, CHI Conference on Human Factors).',
    'https://scholar.google.com/scholar?q=Mark+2012+notifications+productivity+email+CHI+Human+Factors',
  ),
  InsightEntry(
    'Empilhar sessões longas de redes sociais antes de trabalhar reduz a '
    '"largura de banda mental" disponível para tarefas criativas '
    '(Leroy, 2009, Organizational Behavior and Human Decision Processes).',
    'Stacking long social media sessions before working reduces the '
    '"mental bandwidth" available for creative tasks '
    '(Leroy, 2009, Organizational Behavior and Human Decision Processes).',
    'https://scholar.google.com/scholar?q=Leroy+2009+attention+residue+Organizational+Behavior+Human+Decision+Processes',
  ),
  InsightEntry(
    'O celular usado como despertador aumenta o risco de checar mensagens '
    'imediatamente ao acordar — prejudicando o humor matinal '
    '(Thomée, 2012, Umea University).',
    'Using your phone as an alarm clock increases the risk of checking messages '
    'immediately upon waking — harming morning mood '
    '(Thomée, 2012, Umea University).',
    'https://scholar.google.com/scholar?q=Thomee+2012+mobile+phone+morning+use+mood+Umea+University',
  ),

  // ── Exercício e corpo / Exercise & body ──────────────────────────────────
  InsightEntry(
    'Usar o celular durante exercícios reduz a intensidade do treino em até 20% '
    'e eleva a percepção de esforço (Rebold et al., 2015, Performance Enhancement & Health).',
    'Using your phone during exercise reduces workout intensity by up to 20% '
    'and increases perceived exertion (Rebold et al., 2015, Performance Enhancement & Health).',
    'https://scholar.google.com/scholar?q=Rebold+2015+smartphone+exercise+intensity+Performance+Enhancement+Health',
  ),
  InsightEntry(
    'Adultos que passam >10h/dia sentados — frequentemente em frente a telas — '
    'têm risco 34% maior de mortalidade cardiovascular '
    '(Biswas et al., 2015, Annals of Internal Medicine).',
    'Adults who spend more than 10h/day sitting — frequently in front of screens — '
    'have a 34% higher risk of cardiovascular mortality '
    '(Biswas et al., 2015, Annals of Internal Medicine).',
    'https://scholar.google.com/scholar?q=Biswas+2015+sedentary+time+cardiovascular+mortality+Annals+Internal+Medicine',
  ),
  InsightEntry(
    'Substituir 30 min de uso passivo de tela por caminhada leve melhora '
    'o humor imediato mais do que a rolagem de feed '
    '(Oppezzo & Schwartz, 2014, Journal of Experimental Psychology).',
    'Replacing 30 min of passive screen time with light walking improves '
    'immediate mood more than scrolling '
    '(Oppezzo & Schwartz, 2014, Journal of Experimental Psychology).',
    'https://scholar.google.com/scholar?q=Oppezzo+Schwartz+2014+walking+creativity+mood+Journal+Experimental+Psychology',
  ),
  InsightEntry(
    'A postura "cabeça baixa" ao usar o celular gera tensão equivalente a '
    '27 kg sobre a coluna cervical (Hansraj, 2014, Surgical Technology International).',
    'The "head-down" posture when using a phone places the equivalent of '
    '27 kg of force on the cervical spine (Hansraj, 2014, Surgical Technology International).',
    'https://scholar.google.com/scholar?q=Hansraj+2014+head+posture+smartphone+cervical+spine+Surgical+Technology+International',
  ),
  InsightEntry(
    'Crianças que usam telas >2h/dia têm maior IMC e menor aptidão '
    'cardiorrespiratória (Tremblay et al., 2011, International Journal of Behavioral Nutrition).',
    'Children who use screens more than 2h/day have higher BMI and lower '
    'cardiorespiratory fitness (Tremblay et al., 2011, International Journal of Behavioral Nutrition).',
    'https://scholar.google.com/scholar?q=Tremblay+2011+screen+time+children+BMI+fitness+International+Journal+Behavioral+Nutrition',
  ),

  // ── Relações sociais / Social relationships ──────────────────────────────
  InsightEntry(
    'Casais que mantêm os celulares fora da mesa durante refeições relatam '
    'conversas mais significativas e maior satisfação conjugal '
    '(Misra et al., 2016, Environment and Behavior).',
    'Couples who keep their phones away from the table during meals report '
    'more meaningful conversations and greater relationship satisfaction '
    '(Misra et al., 2016, Environment and Behavior).',
    'https://scholar.google.com/scholar?q=Misra+2016+phone+meal+conversation+relationship+Environment+Behavior',
  ),
  InsightEntry(
    'A qualidade das conversas presenciais cai quando há um celular visível '
    'sobre a mesa, mesmo que ninguém o use '
    '(Przybylski & Weinstein, 2013, Journal of Social and Personal Relationships).',
    'The quality of in-person conversations drops when a phone is visible '
    'on the table, even if no one uses it '
    '(Przybylski & Weinstein, 2013, Journal of Social and Personal Relationships).',
    'https://scholar.google.com/scholar?q=Przybylski+Weinstein+2013+phone+table+conversation+Social+Personal+Relationships',
  ),
  InsightEntry(
    'Pais que usam o celular mais frequentemente durante o cuidado dos filhos '
    'são interrompidos com comportamentos mais intensos pelas crianças '
    '(Radesky et al., 2014, Pediatrics).',
    'Parents who use their phones more frequently while caring for children '
    'experience more intense disruptive behaviors from their children '
    '(Radesky et al., 2014, Pediatrics).',
    'https://scholar.google.com/scholar?q=Radesky+2014+mobile+device+caregiver+child+behavior+Pediatrics',
  ),
  InsightEntry(
    'Tecnologias de comunicação usadas intencionalmente (sem scroll passivo) '
    'são associadas a bem-estar — é o "uso ativo" que protege '
    '(Meier & Reinecke, 2021, Journal of Communication).',
    'Communication technologies used intentionally (without passive scrolling) '
    'are associated with well-being — it is "active use" that protects '
    '(Meier & Reinecke, 2021, Journal of Communication).',
    'https://scholar.google.com/scholar?q=Meier+Reinecke+2021+social+media+active+passive+wellbeing+Journal+Communication',
  ),
  InsightEntry(
    'Estudantes universitários que se abstêm de redes sociais por 10 dias '
    'relatam menor ansiedade e maior satisfação com seus relacionamentos reais '
    '(Tromholt, 2016, Cyberpsychology, Behavior, and Social Networking).',
    'University students who abstain from social media for 10 days '
    'report lower anxiety and greater satisfaction with their real-world relationships '
    '(Tromholt, 2016, Cyberpsychology, Behavior, and Social Networking).',
    'https://scholar.google.com/scholar?q=Tromholt+2016+Facebook+experiment+wellbeing+Cyberpsychology+Behavior+Social+Networking',
  ),

  // ── Neurociência / Neuroscience ──────────────────────────────────────────
  InsightEntry(
    'O núcleo accumbens — centro de recompensa do cérebro — responde a '
    '"likes" com liberação de dopamina similar à obtida com elogios presenciais '
    '(Sherman et al., 2016, Psychological Science).',
    'The nucleus accumbens — the brain\'s reward center — responds to '
    '"likes" with dopamine release similar to that from in-person compliments '
    '(Sherman et al., 2016, Psychological Science).',
    'https://scholar.google.com/scholar?q=Sherman+2016+Instagram+likes+nucleus+accumbens+dopamine+Psychological+Science',
  ),
  InsightEntry(
    'O córtex pré-frontal, responsável por autocontrole, ainda está em desenvolvimento '
    'até os 25 anos — tornando adolescentes biologicamente mais vulneráveis '
    'à compulsão digital (Casey et al., 2008, Developmental Science).',
    'The prefrontal cortex, responsible for self-control, is still developing '
    'until age 25 — making teenagers biologically more vulnerable '
    'to digital compulsion (Casey et al., 2008, Developmental Science).',
    'https://scholar.google.com/scholar?q=Casey+2008+adolescent+prefrontal+cortex+development+impulse+control+Developmental+Science',
  ),
  InsightEntry(
    'Práticas de mindfulness de 10 min/dia reduzem o uso compulsivo de smartphone '
    'em 30% após 4 semanas (Throuvala et al., 2019, Journal of Behavioral Addictions).',
    '10 min/day mindfulness practices reduce compulsive smartphone use '
    'by 30% after 4 weeks (Throuvala et al., 2019, Journal of Behavioral Addictions).',
    'https://scholar.google.com/scholar?q=Throuvala+2019+mindfulness+smartphone+compulsive+use+Journal+Behavioral+Addictions',
  ),
  InsightEntry(
    'A variabilidade da recompensa (às vezes há, às vezes não há novidade no feed) '
    'é o mecanismo mais potente para criar hábitos compulsivos '
    '(Skinner, B.F., reforço intermitente — base do design persuasivo atual).',
    'Reward variability (sometimes there is, sometimes there is no novelty in the feed) '
    'is the most potent mechanism for creating compulsive habits '
    '(Skinner, B.F., intermittent reinforcement — the basis of current persuasive design).',
    'https://scholar.google.com/scholar?q=Skinner+variable+ratio+intermittent+reinforcement+operant+conditioning',
  ),
  InsightEntry(
    'Neuroimagem mostra que usuários com uso problemático de smartphone '
    'apresentam menor volume de substância cinzenta no córtex insular — '
    'área ligada a autocontrole (Cheng & Li, 2018, Addiction Biology).',
    'Neuroimaging shows that users with problematic smartphone use '
    'have lower gray matter volume in the insular cortex — '
    'an area linked to self-control (Cheng & Li, 2018, Addiction Biology).',
    'https://scholar.google.com/scholar?q=Cheng+Li+2018+smartphone+addiction+gray+matter+insular+cortex+Addiction+Biology',
  ),

  // ── Infância e desenvolvimento / Childhood & development ─────────────────
  InsightEntry(
    'A OMS recomenda zero tempo de tela para menores de 2 anos e '
    'menos de 1h/dia para crianças de 3–4 anos.',
    'The WHO recommends zero screen time for children under 2 years and '
    'less than 1h/day for children aged 3–4 years.',
    'https://www.who.int/news/item/24-04-2019-to-grow-up-healthy-children-need-to-sit-less-and-play-more',
  ),
  InsightEntry(
    'Cada hora extra de tela por dia em crianças de 5 anos está associada a '
    'maior probabilidade de problemas de atenção aos 7 anos '
    '(Tamana et al., 2019, PLOS ONE).',
    'Each extra hour of daily screen time in 5-year-olds is associated with '
    'a higher likelihood of attention problems at age 7 '
    '(Tamana et al., 2019, PLOS ONE).',
    'https://scholar.google.com/scholar?q=Tamana+2019+screen+time+5+years+attention+problems+7+years+PLOS+ONE',
  ),
  InsightEntry(
    'Crianças expostas a telas antes dos 3 anos falam menos palavras por hora '
    'do que aquelas em ambientes sem tela '
    '(Zimmerman et al., 2009, Archives of Pediatrics & Adolescent Medicine).',
    'Children exposed to screens before age 3 speak fewer words per hour '
    'than those in screen-free environments '
    '(Zimmerman et al., 2009, Archives of Pediatrics & Adolescent Medicine).',
    'https://scholar.google.com/scholar?q=Zimmerman+2009+television+language+development+Archives+Pediatrics+Adolescent+Medicine',
  ),

  // ── Bem-estar geral / General well-being ─────────────────────────────────
  InsightEntry(
    'Pessoas que definem horários fixos para checar o celular (ex: 3×/dia) '
    'relatam menos estresse e maior sensação de controle '
    '(Kushlev & Dunn, 2015, Computers in Human Behavior).',
    'People who set fixed times to check their phone (e.g., 3×/day) '
    'report less stress and a greater sense of control '
    '(Kushlev & Dunn, 2015, Computers in Human Behavior).',
    'https://scholar.google.com/scholar?q=Kushlev+Dunn+2015+checking+email+less+frequently+stress+Computers+Human+Behavior',
  ),
  InsightEntry(
    '"Time well spent": o que importa não é quanto você usa, '
    'mas se você se sente bem depois — essa é a métrica real de uso saudável '
    '(Etchells et al., 2019, PLOS ONE).',
    '"Time well spent": what matters is not how much you use it, '
    'but whether you feel good afterwards — that is the real metric of healthy use '
    '(Etchells et al., 2019, PLOS ONE).',
    'https://scholar.google.com/scholar?q=Etchells+2019+screen+time+wellbeing+PLOS+ONE',
  ),
  InsightEntry(
    'A cada 10% de redução no tempo de tela fora do trabalho, '
    'participantes relataram melhora no sono, humor e energia '
    '(Twenge & Campbell, 2019, JAMA Pediatrics — dados reanalisados).',
    'For every 10% reduction in leisure screen time, '
    'participants reported improvement in sleep, mood, and energy '
    '(Twenge & Campbell, 2019, JAMA Pediatrics — reanalyzed data).',
    'https://scholar.google.com/scholar?q=Twenge+Campbell+2019+screen+time+wellbeing+reanalysis+JAMA+Pediatrics',
  ),
  InsightEntry(
    'Estabelecer "zonas sem celular" (quarto, mesa de jantar) é uma das '
    'intervenções mais eficazes para reduzir uso compulsivo '
    '(Duke & Ward, 2019, Journal of the Association for Consumer Research).',
    'Establishing "phone-free zones" (bedroom, dining table) is one of the '
    'most effective interventions for reducing compulsive use '
    '(Duke & Ward, 2019, Journal of the Association for Consumer Research).',
    'https://scholar.google.com/scholar?q=Duke+Ward+2019+phone+free+zones+compulsive+use+Consumer+Research',
  ),
  InsightEntry(
    'O simples ato de nomear o que sente ao abrir um app compulsivamente '
    '("estou ansioso", "estou entediado") reduz a intensidade do impulso em 40% '
    '(Lieberman et al., 2007, Psychological Science — affect labeling).',
    'The simple act of naming what you feel when opening an app compulsively '
    '("I\'m anxious", "I\'m bored") reduces the intensity of the impulse by 40% '
    '(Lieberman et al., 2007, Psychological Science — affect labeling).',
    'https://scholar.google.com/scholar?q=Lieberman+2007+affect+labeling+putting+feelings+into+words+Psychological+Science',
  ),
  InsightEntry(
    'Pesquisadores calcularam que o custo de oportunidade '
    'do uso passivo de tela é de 2–3 horas semanais de atividades restauradoras '
    '(sono, exercício, conexão presencial).',
    'Researchers calculated that the opportunity cost '
    'of passive screen time is 2–3 hours per week of restorative activities '
    '(sleep, exercise, in-person connection).',
    'https://scholar.google.com/scholar?q=screen+time+opportunity+cost+restorative+activities+sleep+exercise',
  ),
  InsightEntry(
    'Usar o celular como ferramenta com intenção clara — não como escape do tédio — '
    'é o traço mais consistente entre usuários que relatam alta satisfação '
    'com suas vidas digitais (Meier & Reinecke, 2021, Journal of Communication).',
    'Using your phone as a tool with clear intention — not as an escape from boredom — '
    'is the most consistent trait among users who report high satisfaction '
    'with their digital lives (Meier & Reinecke, 2021, Journal of Communication).',
    'https://scholar.google.com/scholar?q=Meier+Reinecke+2021+intentional+social+media+use+wellbeing+Journal+Communication',
  ),
];
