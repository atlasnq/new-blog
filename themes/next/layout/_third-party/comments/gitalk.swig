{% if page.comments && theme.gitalk.enable %}
  <link rel="stylesheet" href="/css/gitalk.css">
  <script src="/js/src/gitalk.min.js"></script>
  <div id="gitalk-container"></div>
  <script src="/js/src/md5.min.js"></script>
  <script type="text/javascript">
    var gitalk = new Gitalk({
      clientID: '{{ theme.gitalk.clientID }}',
      clientSecret: '{{ theme.gitalk.clientSecret }}',
      repo: '{{ theme.gitalk.repo }}',
      owner: '{{ theme.gitalk.owner }}',
      admin: ['{{ theme.gitalk.admin }}'],
      id: md5(location.pathname),
      distractionFreeMode: '{{ theme.gitalk.distractionFreeMode }}'
    })
    gitalk.render('gitalk-container')
  </script>
{% endif %}