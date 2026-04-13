import 'package:flutter/material.dart';
import 'app_localizations.dart';

class AppLocalizationsPt extends AppLocalizations {
  const AppLocalizationsPt(Locale locale) : super(locale);

  @override String get navHome => 'Início';
  @override String get navAnalysis => 'Análise';
  @override String get navInsights => 'Insights';
  @override String get navSettings => 'Config.';

  @override String get cancel => 'Cancelar';
  @override String get save => 'Salvar';
  @override String get noData => 'Sem dados ainda.';
  @override String get collectingData => 'Coletando dados — volte mais tarde.';

  @override String get permFloatingWindow => 'Janela flutuante';
  @override String get permUsageStats => 'Estatísticas de uso';
  @override String get permGranted => 'Concedida';
  @override String get permRequired => 'Necessária';
  @override String get permGrant => 'Conceder';
  @override String get insightOfDay => 'Insight do dia';
  @override String get monitoringTitle => 'Contador';
  @override String get monitoringActive => 'Ativo — overlay mostrando uso em tempo real.';
  @override String get monitoringInactive => 'Inativo. Toque em Iniciar.';
  @override String get monitoringNoPerms => 'Conceda as permissões acima para iniciar.';
  @override String get monitoringDesc =>
      'O overlay exibe quantas vezes você abriu o app (5s) e o tempo acumulado.';
  @override String get actionStart => 'Iniciar';
  @override String get actionStop => 'Parar';

  @override String get onboardWelcomeTitle => 'Bem-vindo ao AppTime';
  @override String get onboardWelcomeBody =>
      'Consciência sem bloqueio.\n\n'
      'O AppTime mostra, em tempo real, quantas vezes você abriu cada app '
      'e quanto tempo você passou nele — direto na sua tela, como um '
      'relógio discreto.\n\n'
      'Precisamos de 2 permissões para funcionar.';
  @override String get onboardStart => 'Começar';
  @override String get onboardPermOverlayTitle => 'Janela flutuante';
  @override String get onboardPermOverlayDesc =>
      'O AppTime precisa desta permissão para mostrar o '
      'contador de uso em tempo real sobre outros apps, sem '
      'interromper o que você está fazendo.';
  @override String get onboardPermUsageTitle => 'Estatísticas de uso';
  @override String get onboardPermUsageDesc =>
      'Esta permissão permite que o AppTime acesse quais apps '
      'estão em primeiro plano para contabilizar seu tempo de uso com '
      'precisão.';
  @override String get permGrantedLabel => 'Permissão concedida';
  @override String get permSettingsHint =>
      'Você será direcionado para as configurações do sistema. '
      'Conceda a permissão e volte ao app.';
  @override String get openSettings => 'Abrir configurações';
  @override String get continueAction => 'Continuar';

  @override String get settingsTitle => 'Configurações';
  @override String get sectionOverlay => 'Overlay';
  @override String get showBorder => 'Mostrar borda';
  @override String get showBackground => 'Mostrar fundo';
  @override String fontSize(int size) => 'Tamanho da fonte: ${size}sp';
  @override String get sectionPositioning => 'Posicionamento';
  @override String verticalPosition(int dp) => 'Posição vertical: ${dp}dp';
  @override String get sectionBehavior => 'Comportamento';
  @override String get dailyGoalTitle => 'Meta diária de uso';
  @override String get noGoalSet => 'Sem meta definida';
  @override String goalMinutesPerDay(int min) => '$min minutos / dia';
  @override String get perAppControlTitle => 'Controle por app';
  @override String get perAppControlSub => 'Habilitar / desabilitar overlay por app';
  @override String get monitorLauncherTitle => 'Monitorar tela inicial';
  @override String get monitorLauncherSub => 'Mostrar overlay na tela inicial / launcher';
  @override String get dialogDailyGoalTitle => 'Meta diária';
  @override String get dialogNoGoal => 'Sem meta';
  @override String dialogGoalMinDay(int min) => '$min min / dia';
  @override String get sectionLanguage => 'Idioma';
  @override String get languageSystem => 'Sistema';
  @override String get languagePtBr => 'Português (Brasil)';
  @override String get languageEn => 'English';

  @override String get perAppTitle => 'Controle por app';
  @override String get noAppsMsg =>
      'Nenhum app registrado nos últimos 7 dias.\n'
      'Inicie o monitoramento e use o celular normalmente.';
  @override String get overlayDisabled => 'Overlay desabilitado';
  @override String get overlayActive => 'Overlay ativo';

  @override String get analysisTitle => 'Análise';
  @override String get tab24h => '24h';
  @override String get tab7d => '7 dias';
  @override String get tab30d => '30 dias';
  @override String get statTotalUsage => 'Uso total';
  @override String get statUnlocks => 'Desbloqueios';
  @override String get statTotalTime => 'Tempo total';
  @override String get noSessions => 'Nenhuma sessão registrada ainda.';
  @override String get dailyUsageLabel => 'Uso diário';
  @override String get passive => 'Passivo';
  @override String get active => 'Ativo';
  @override String get prevWeekLabel => 'semana anterior';
  @override String pagesLabel(int n) => '$n páginas';
  @override String kmLabel(int n) => '${n}km';
  @override String sleepCyclesLabel(int n) => '$n ciclos';

  @override String get blockSleepTitle => 'Higiene do sono';
  @override String blockSleepText(int pct) =>
      'Seu uso entre 22h e 6h representa $pct% do tempo total. '
      'A luz azul nesse período pode atrasar a secreção de melatonina '
      'em até 30 minutos, prejudicando a fase REM do sono.';
  @override String get blockImpulsivityTitle => 'Índice de impulsividade';
  @override String blockImpulsivityText(int unlocks) =>
      'Você desbloqueou o celular $unlocks vezes hoje. '
      'A frequência de desbloqueios é um preditor mais forte de ansiedade '
      'e baixa qualidade de sono do que o tempo total de tela.';
  @override String get blockFocusTitle => 'Fragmentação do foco';
  @override String blockFocusText(int pct) =>
      '$pct% das suas sessões duraram menos de 60 segundos. '
      'Esse "hábito de checar" fragmenta a atenção e impede o estado de '
      'foco profundo (Flow). Usuários com alta fragmentação levam até 20% '
      'mais tempo para completar tarefas complexas.';
  @override String get blockOpportunityTitle => 'Custo de oportunidade';
  @override String get blockOpportunityText =>
      'Cada hora de uso passivo é uma hora que poderia ser '
      'dedicada a sono reparador, exercício ou conexão presencial.';
  @override String get blockPhubbingTitle => 'Alerta de phubbing';
  @override String blockPhubbingText(int unlocks) =>
      'Você desbloqueou o celular $unlocks vezes nos horários de '
      'almoço e jantar. O phubbing — ignorar quem está presente para '
      'olhar o celular — enfraquece laços sociais e aumenta sentimentos '
      'de solidão a longo prazo.';
  @override String get blockDopamineTitle => 'Dreno de dopamina';
  @override String blockDopamineText(String app, int opens) =>
      'O app "$app" foi seu maior gatilho: $opens aberturas em 7 dias. '
      'Apps de scroll infinito são projetados como "caça-níqueis" — '
      'recompensa intermitente que cria ciclos compulsivos difíceis de quebrar.';
  @override String get blockDopamineNoData => 'Nenhum dado ainda.';
  @override String get blockEngagementTitle => 'Balanço de engajamento';
  @override String blockEngagementText(int pct) =>
      'Seu uso foi $pct% passivo esta semana. '
      'O consumo passivo de feed (sem interagir) está ligado a ruminação '
      'e sintomas de depressão, enquanto o uso ativo (mensagens reais) '
      'pode ter efeito protetor na saúde mental.';
  @override String get blockEngagementNoData => 'Sem dados ainda.';
  @override String get blockTrendTitle => 'Tendência semanal';
  @override String blockTrendReduced(int pct) =>
      'Você reduziu seu uso em $pct% vs. a semana anterior. '
      'Manter essa tendência por 21 dias é o marco científico '
      'para a reformulação de hábitos neurais.';
  @override String blockTrendIncreased(int pct) =>
      'Seu uso aumentou $pct% vs. a semana anterior. '
      'Tente identificar os gatilhos que levaram ao aumento.';
  @override String get blockTrend30Title => 'Tendência 30 dias';
  @override String get blockTrend30Text =>
      'Manter uma tendência de queda por 21 dias consecutivos é '
      'o marco científico para a reformulação de circuitos de hábito '
      'e fortalecimento do córtex pré-frontal.';
  @override String get blockWeekendTitle => 'Padrão de fim de semana';
  @override String blockWeekendSpikeText(int pct) =>
      'Seu uso aumenta $pct% nos finais de semana. '
      'Embora pareça lazer, o uso excessivo nos dias de descanso '
      'impede a recuperação cognitiva do estresse semanal.';
  @override String get blockWeekendNoSpike =>
      'Seu uso no fim de semana é similar ao dos dias úteis. '
      'Isso pode indicar um padrão de uso crônico ou '
      'uma rotina saudável e consistente.';

  @override String get insightsTitle => 'Insights';
  @override String get tabAlerts => 'Alertas';
  @override String get tabSolutions => 'Soluções';

  @override String get goalScreenTitle => 'Metas de uso';
  @override String get goalLevelSectionTitle => 'Nível de meta';
  @override String get goalLevelNone => 'Nenhum';
  @override String get goalLevelMinimal => 'Mínimo';
  @override String get goalLevelNormal => 'Normal';
  @override String get goalLevelExtensive => 'Extensivo';
  @override String get goalRationaleNone =>
      'Apenas consciência — sem feedback ativo. Ideal para começar a '
      'entender seus padrões sem pressão.';
  @override String get goalRationaleMinimal =>
      'Limites rigorosos baseados em pesquisas sobre bem-estar digital. '
      'Recomendado para quem quer reduzir o uso significativamente.';
  @override String get goalRationaleNormal =>
      'Equilíbrio entre produtividade e lazer digital. Alinha-se com '
      'recomendações de especialistas em saúde mental para adultos.';
  @override String get goalRationaleExtensive =>
      'Limites relaxados, mas com feedback ativo. Ideal para quem quer '
      'monitorar sem restrições severas.';
  @override String get goalPerAppTitle => 'Metas por app';
  @override String get goalPerAppSub =>
      'Substitua a meta global para apps específicos.';
  @override String get goalOverrideGlobal => 'Global';
  @override String get goalSettingsTile => 'Metas de uso';
  @override String get goalSettingsSub => 'Níveis de feedback e limites por app';
}
